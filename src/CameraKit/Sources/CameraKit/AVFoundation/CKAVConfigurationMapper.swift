import AVFoundation

struct CKAVMapperKey: Hashable {
  let deviceId: CKDeviceID
  let configurationId: CKDeviceConfigurationID
}

extension CKDevice where Configuration: Identifiable, Configuration.ID == CKDeviceConfigurationID {
  var key: CKAVMapperKey {
    CKAVMapperKey(deviceId: id, configurationId: configuration.id)
  }
}

protocol CKAVConfigurationMapper {
  var currentConfiguration: CKAdjustableConfiguration { get }
  func avCaptureDevice(_ key: CKAVMapperKey) -> AVCaptureDevice?
  func avFormat(_ key: CKAVMapperKey) -> AVCaptureDevice.Format?
  func id(_ device: AVCaptureDevice) -> CKAVMapperKey?
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

  func avCaptureDevice(_ key: CKAVMapperKey) -> AVCaptureDevice? {
    tryInitialize()
    return deviceMap[key]
  }

  func avFormat(_ key: CKAVMapperKey) -> AVCaptureDevice.Format? {
    tryInitialize()
    return formatMap[key]
  }

  func id(_ device: AVCaptureDevice) -> CKAVMapperKey? {
    tryInitialize()
    return reverseDeviceMap[device]
  }

  func add(cameras: [AVCaptureDevice], deviceId: CKDeviceID) -> CKDevice<[CKAdjustableCameraConfiguration]>? {
    let confs = cameras.flatMap { device in
      device.formats.map { format in
        let conf = adjustableCameraConfiguration(device: device, format: format)
        let key = CKAVMapperKey(deviceId: deviceId, configurationId: conf.id)
        formatMap[key] = format
        deviceMap[key] = device
        reverseDeviceMap[device] = key
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
      fieldOfView: Int(format.videoFieldOfView),
      supportedStabilizationModes: CKStabilizationMode.allCases.filter {
        format.isVideoStabilizationModeSupported($0.avStabilizationMode)
      },
      isMulticamAvailable: AVCaptureMultiCamSession.isMultiCamSupported && format.isMultiCamSupported
    )
  }

  private var deviceMap: [CKAVMapperKey: AVCaptureDevice] = [:]
  private var formatMap: [CKAVMapperKey: AVCaptureDevice.Format] = [:]
  private var reverseDeviceMap: [AVCaptureDevice: CKAVMapperKey] = [:]
  private var initialized = false
  private var configuration: CKAdjustableConfiguration!

  private func tryInitialize() {
    guard !initialized else { return }
    discovery.microphone.u
    let backCamera = add(cameras: discovery.backCameras, deviceId: CKCameraDeviceID.back)
    let frontCamera = add(cameras: discovery.frontCameras, deviceId: CKCameraDeviceID.front)
    let cameras = [backCamera, frontCamera].compactMap { $0 }.map { ($0.id, $0) }
    configuration = CKAdjustableConfiguration(
      cameras: Dictionary(uniqueKeysWithValues: cameras),
      microphone: nil
    )
  }
}
