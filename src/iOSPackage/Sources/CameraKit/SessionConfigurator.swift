import AVFoundation
import Device
import Util
import Combine

public protocol SessionConfigurator {
  func configure(session: Session, deviceConfiguration: DeviceConfiguration) throws
}

public enum SessionConfiguratorStub: SessionConfigurator {
  case shared

  public func configure(session: Session, deviceConfiguration: DeviceConfiguration) throws {
  }
}

final class SessionConfiguratorImpl: SessionConfigurator {
  private let discovery = Discovery()
  private weak var session: Session?

  func configure(session: Session, deviceConfiguration: DeviceConfiguration) throws {
    self.session = session
    try installCameras(deviceConfiguration: deviceConfiguration)
    try SessionMicrophoneConfigurator().configure(configuration: deviceConfiguration.microphone)
  }

  private func installCameras(deviceConfiguration: DeviceConfiguration) throws {
    if let frontCamera = deviceConfiguration.frontCamera, let backCamera = deviceConfiguration.backCamera {
      let multiSet = try find(backCamera: backCamera, frontCamera: frontCamera)
      session?.avSession.beginConfiguration()
      defer { session?.avSession.commitConfiguration() }
      try install(deviceWithFormat: multiSet[0], deviceConfiguration: deviceConfiguration, isFront: false)
      try install(deviceWithFormat: multiSet[1], deviceConfiguration: deviceConfiguration, isFront: true)
    } else if let frontCamera = deviceConfiguration.frontCamera {
      let frontDevice = try find(isFront: true, configuration: frontCamera)
      session?.avSession.beginConfiguration()
      defer { session?.avSession.commitConfiguration() }
      try install(deviceWithFormat: frontDevice, deviceConfiguration: deviceConfiguration, isFront: true)
    } else if let backCamera = deviceConfiguration.backCamera {
      let backDevice = try find(isFront: false, configuration: backCamera)
      session?.avSession.beginConfiguration()
      defer { session?.avSession.commitConfiguration() }
      try install(deviceWithFormat: backDevice, deviceConfiguration: deviceConfiguration, isFront: false)
    }
  }

  private func install(
    deviceWithFormat: DeviceWithFormat,
    deviceConfiguration: DeviceConfiguration,
    isFront: Bool
  ) throws {
    let configuration = isFront ? deviceConfiguration.frontCamera : deviceConfiguration.backCamera
    guard let configuration, let input = makeInput(device: deviceWithFormat.device) else {
      log.warn("[isFront=\(isFront)] Configuration not applied, input not created")
      throw SessionConfiguratorError.camera(isFront: isFront, .connectionError)
    }
    guard let session else { return }
    guard let previewView = isFront ? session.frontCameraPreviewView : session.backCameraPreviewView else { return }
    let cameraConfigurator = SessionCameraConfigurator(
      session: session.avSession,
      deviceWithFormat: deviceWithFormat,
      configuration: configuration,
      input: input,
      output: isFront ? session.frontOutput : session.backOutput,
      previewView: previewView,
      orientation: deviceConfiguration.orientation
    )
    do {
      try cameraConfigurator.addInputOutput()
      cameraConfigurator.configurePreviewView()
      try cameraConfigurator.addConnections()
      try cameraConfigurator.configureDevice()
    } catch {
      log.warn(error: error)
      log.warn("[isFront=\(isFront)] Configuration not applied on final step")
      throw SessionConfiguratorError.camera(isFront: isFront, .connectionError)
    }
  }

  private func find(isFront: Bool, configuration: CameraConfiguration) throws -> DeviceWithFormat {
    let devices = isFront ? discovery.frontCameras : discovery.backCameras
    let candidates = devices
      .flatMap { device in device.formats.map { format in (device, format) } }
      .filter { (_, format) in format.fov == configuration.fov && format.resolution == configuration.resolution }
    if candidates.isEmpty {
      throw SessionConfiguratorError.camera(isFront: isFront, .fields(fields: [\.resolution, \.fov]))
    } else {
      let candidate = candidates.first { (_, format) in
        format.canApply(fps: configuration.fps) && format.canApply(zoom: configuration.zoom)
      }
      if let candidate {
        return .init(device: candidate.0, format: candidate.1)
      }
    }
    throw SessionConfiguratorError.camera(isFront: isFront, .fields(fields: [\.zoom, \.fps]))
  }

  private func find(backCamera: CameraConfiguration, frontCamera: CameraConfiguration) throws -> [DeviceWithFormat] {
    var foundFovResolution = false
    for (frontDevice, backDevice) in discovery.multiCameraDeviceSets {
      for (frontFormat, backFormat) in zip(frontDevice.formats, backDevice.formats) {
        foundFovResolution = foundFovResolution ||
          (frontFormat.fov == frontCamera.fov && frontFormat.resolution == frontCamera.resolution &&
          backFormat.fov == backCamera.fov && backCamera.resolution == backCamera.resolution)
        guard foundFovResolution else { continue }
        let matches = frontFormat.canApply(fps: frontCamera.fps) && frontFormat.canApply(zoom: frontCamera.zoom) &&
          backFormat.canApply(fps: backCamera.fps) && backFormat.canApply(fps: backCamera.fps)
        guard matches else { continue }
        let frontDWF = DeviceWithFormat(device: frontDevice, format: frontFormat)
        let backDWF = DeviceWithFormat(device: backDevice, format: backFormat)
        return [backDWF, frontDWF]
      }
    }
    let fields = SessionConfiguratorError.CameraError.fields(
      fields: foundFovResolution ? [\.zoom, \.fps] : [\.resolution, \.fov]
    )
    throw SessionConfiguratorError.camera(front: fields, back: fields)
  }
}

private func makeInput(device: AVCaptureDevice) -> AVCaptureDeviceInput? {
  do {
    let input = try AVCaptureDeviceInput(device: device)
    return input
  } catch {
    log.warn(error: error)
    return nil
  }
}

private extension AVCaptureDevice.Format {
  var resolution: Resolution {
    let fmtDesc = CMVideoFormatDescriptionGetDimensions(formatDescription)
    return Resolution(width: Int(fmtDesc.width), height: Int(fmtDesc.height))
  }

  var fov: Int {
    Int(videoFieldOfView)
  }

  func canApply(fps: Int) -> Bool {
    let floatFps = Float64(fps)
    return videoSupportedFrameRateRanges.contains { range in
      (range.minFrameRate...range.maxFrameRate).contains(floatFps)
    }
  }

  func canApply(zoom: Double) -> Bool {
    (1...Double(videoMaxZoomFactor)).contains(zoom)
  }
}
