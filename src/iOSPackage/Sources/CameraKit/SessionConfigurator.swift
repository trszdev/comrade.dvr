import AVFoundation
import Device
import Util
import Combine

public protocol SessionConfigurator {
  func update(
    frontCamera: CameraConfiguration?,
    backCamera: CameraConfiguration?,
    microphone: MicrophoneConfiguration?
  ) async

  var frontCameraErrorPublisher: AnyPublisher<SessionConfiguratorCameraError?, Never> { get }
  var backCameraErrorPublisher: AnyPublisher<SessionConfiguratorCameraError?, Never> { get }
  var microphoneErrorPublisher: AnyPublisher<SessionConfiguratorMicrophoneError?, Never> { get }
}

public struct SessionConfiguratorStub: SessionConfigurator {
  public func update(
    frontCamera: CameraConfiguration?,
    backCamera: CameraConfiguration?,
    microphone: MicrophoneConfiguration?
  ) async {
    try? await Task.sleep(.seconds(5))
  }

  public var frontCameraErrorPublisher: AnyPublisher<SessionConfiguratorCameraError?, Never> {
    CurrentValueSubject(nil).eraseToAnyPublisher()
  }

  public var backCameraErrorPublisher: AnyPublisher<SessionConfiguratorCameraError?, Never> {
    CurrentValueSubject(nil).eraseToAnyPublisher()
  }

  public var microphoneErrorPublisher: AnyPublisher<SessionConfiguratorMicrophoneError?, Never> {
    CurrentValueSubject(nil).eraseToAnyPublisher()
  }

  public init() {}
}

final class SessionConfiguratorImpl: SessionConfigurator {
  private weak var store: SessionStore?
  private let discovery = Discovery()

  init(store: SessionStore?) {
    self.store = store
  }

  func update(
    frontCamera: CameraConfiguration?,
    backCamera: CameraConfiguration?,
    microphone: MicrophoneConfiguration?
  ) async {
    store?.recreateSession(backCamera: backCamera, frontCamera: frontCamera)
    installCameras(frontCamera: frontCamera, backCamera: backCamera)
    microphoneErrorSubject.value = SessionMicrophoneConfigurator().configureAndGetError(configuration: microphone)
  }

  private let frontCameraErrorSubject = CurrentValueSubject<SessionConfiguratorCameraError?, Never>(nil)
  private let backCameraErrorSubject = CurrentValueSubject<SessionConfiguratorCameraError?, Never>(nil)
  private let microphoneErrorSubject = CurrentValueSubject<SessionConfiguratorMicrophoneError?, Never>(nil)

  var frontCameraErrorPublisher: AnyPublisher<SessionConfiguratorCameraError?, Never> {
    frontCameraErrorSubject.eraseToAnyPublisher()
  }
  var backCameraErrorPublisher: AnyPublisher<SessionConfiguratorCameraError?, Never> {
    backCameraErrorSubject.eraseToAnyPublisher()
  }
  var microphoneErrorPublisher: AnyPublisher<SessionConfiguratorMicrophoneError?, Never> {
    microphoneErrorSubject.eraseToAnyPublisher()
  }

  private func installCameras(frontCamera: CameraConfiguration?, backCamera: CameraConfiguration?) {
    if let frontCamera, let backCamera {
      let multiSet = findMulti(backCamera: backCamera, frontCamera: frontCamera)
      guard multiSet.isEmpty else { return }
      store?.session?.currentSession.beginConfiguration()
      tryInstall(deviceWithFormat: multiSet[0], configuration: backCamera, isFront: false)
      tryInstall(deviceWithFormat: multiSet[1], configuration: frontCamera, isFront: true)
      store?.session?.currentSession.commitConfiguration()
    } else if let frontCamera {
      guard let frontDevice = tryFind(isFront: true, configuration: frontCamera) else { return }
      store?.session?.currentSession.beginConfiguration()
      tryInstall(deviceWithFormat: frontDevice, configuration: frontCamera, isFront: true)
      store?.session?.currentSession.commitConfiguration()
    } else if let backCamera {
      guard let backDevice = tryFind(isFront: false, configuration: backCamera) else { return }
      store?.session?.currentSession.beginConfiguration()
      tryInstall(deviceWithFormat: backDevice, configuration: backCamera, isFront: false)
      store?.session?.currentSession.commitConfiguration()
    }
  }

  private func tryInstall(deviceWithFormat: DeviceWithFormat, configuration: CameraConfiguration, isFront: Bool) {
    let errorSubject = isFront ? frontCameraErrorSubject : backCameraErrorSubject
    guard let input = makeInput(device: deviceWithFormat.device) else {
      log.warn("[isFront=\(isFront)] Configuration not applied, input not created")
      errorSubject.value = .connectionError
      return
    }
    guard let session = store?.session else { return }
    let cameraConfigurator = SessionCameraConfigurator(
      session: session.currentSession,
      deviceWithFormat: deviceWithFormat,
      configuration: configuration,
      input: input,
      output: isFront ? session.frontOutput : session.backOutput,
      previewView: isFront ? session.frontCameraPreviewView : session.backCameraPreviewView
    )
    do {
      try cameraConfigurator.addInputOutput()
      cameraConfigurator.configurePreviewView()
      try cameraConfigurator.addConnections()
      try cameraConfigurator.configureDevice()
    } catch {
      errorSubject.value = .connectionError
      log.warn(error: error)
      log.warn("[isFront=\(isFront)] Configuration not applied on final step")
    }
  }

  private func tryFind(isFront: Bool, configuration: CameraConfiguration) -> DeviceWithFormat? {
    let errorSubject = isFront ? frontCameraErrorSubject : backCameraErrorSubject
    let devices = isFront ? discovery.frontCameras : discovery.backCameras
    let candidates = devices
      .flatMap { device in device.formats.map { format in (device, format) } }
      .filter { (_, format) in format.fov == configuration.fov && format.resolution == configuration.resolution }
    if candidates.isEmpty {
      errorSubject.value = .fields(fields: [\.resolution, \.fov])
    } else {
      let candidate = candidates.first { (_, format) in
        format.canApply(fps: configuration.fps) && format.canApply(zoom: configuration.zoom)
      }
      if let candidate {
        return .init(device: candidate.0, format: candidate.1)
      }
    }
    errorSubject.value = .fields(fields: [\.zoom, \.fps])
    return nil
  }

  private func findMulti(backCamera: CameraConfiguration, frontCamera: CameraConfiguration) -> [DeviceWithFormat] {
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
    let fields = SessionConfiguratorCameraError.fields(
      fields: foundFovResolution ? [\.zoom, \.fps] : [\.resolution, \.fov]
    )
    frontCameraErrorSubject.value = fields
    backCameraErrorSubject.value = fields
    return []
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
