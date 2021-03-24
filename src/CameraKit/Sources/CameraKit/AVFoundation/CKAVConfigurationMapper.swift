import AVFoundation

protocol CKAVConfigurationMapper {
  var currentConfiguration: CKAdjustableConfiguration { get }
  func avCaptureDevice(_ deviceId: CKDeviceID, _ configurationId: CKDeviceConfigurationID) -> AVCaptureDevice?
}

final class CKAVConfigurationMapperImpl: CKAVConfigurationMapper {
  let discovery: CKAVDiscovery

  init(discovery: CKAVDiscovery) {
    self.discovery = discovery
  }

  var currentConfiguration: CKAdjustableConfiguration {
    tryInitialize()
    return configuration
  }

  func avCaptureDevice(_ deviceId: CKDeviceID, _ configurationId: CKDeviceConfigurationID) -> AVCaptureDevice? {
    tryInitialize()
    return deviceMap[CKMapperKey(deviceId: deviceId, configurationId: configurationId)]
  }

  func add(cameras: [AVCaptureDevice], deviceId: CKDeviceID) -> CKDevice<[CKAdjustableCameraConfiguration]>? {
    let confs = cameras.flatMap { device in
      device.formats.map { format in
        let conf = adjustableCameraConfiguration(device: device, format: format)
        deviceMap[CKMapperKey(deviceId: deviceId, configurationId: conf.id)] = device
        return conf
      } as [CKAdjustableCameraConfiguration]
    }
    return confs.isEmpty ? nil : CKDevice(id: deviceId, configuration: confs)
  }

  private func adjustableCameraConfiguration(
    device: AVCaptureDevice,
    format: AVCaptureDevice.Format
  ) -> CKAdjustableCameraConfiguration {
    CKAdjustableCameraConfiguration(
      id: CKDeviceConfigurationID(value: device.uniqueID + format.description),
      size: format.size,
      minZoom: 1,
      maxZoom: Double(format.videoMaxZoomFactor),
      minFps: (format.videoSupportedFrameRateRanges.first?.minFrameRate).flatMap(Int.init) ?? 1,
      maxFps: (format.videoSupportedFrameRateRanges.first?.maxFrameRate).flatMap(Int.init) ?? 30,
      fieldOfView: Double(format.videoFieldOfView),
      isVideoMirroringAvailable: false, // TODO
      supportedStabilizationModes: CKStabilizationMode.allCases.filter {
        format.isVideoStabilizationModeSupported($0.avStabilizationMode)
      },
      isMulticamAvailable: AVCaptureMultiCamSession.isMultiCamSupported && format.isMultiCamSupported
    )
  }

  private var deviceMap: [CKMapperKey: AVCaptureDevice] = [:]
  private var initialized = false
  private var configuration: CKAdjustableConfiguration!

  private func tryInitialize() {
    guard !initialized else { return }
    let backCamera = add(cameras: discovery.backCameras, deviceId: backCameraId)
    let frontCamera = add(cameras: discovery.frontCameras, deviceId: frontCameraId)
    let cameras = [backCamera, frontCamera].compactMap { $0 }.map { ($0.id, $0) }
    configuration = CKAdjustableConfiguration(
      cameras: Dictionary(uniqueKeysWithValues: cameras),
      microphone: nil
    )
  }
}

private let frontCameraId = CKDeviceID(value: "front-camera")
private let backCameraId = CKDeviceID(value: "back-camera")

private struct CKMapperKey: Hashable {
  let deviceId: CKDeviceID
  let configurationId: CKDeviceConfigurationID
}
