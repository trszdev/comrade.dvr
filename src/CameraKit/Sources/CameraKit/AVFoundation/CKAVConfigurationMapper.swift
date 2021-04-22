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
  func camera(_ device: AVCaptureDevice) -> CKDevice<[CKAdjustableCameraConfiguration]>?

  func audioInput(_ key: CKAVMapperKey) -> AVAudioSessionPortDescription?
  func audioDataSource(_ key: CKAVMapperKey) -> AVAudioSessionDataSourceDescription?
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

  func camera(_ device: AVCaptureDevice) -> CKDevice<[CKAdjustableCameraConfiguration]>? {
    tryInitialize()
    return cameras[device]
  }

  func audioInput(_ key: CKAVMapperKey) -> AVAudioSessionPortDescription? {
    tryInitialize()
    return audioInputMap[key]
  }

  func audioDataSource(_ key: CKAVMapperKey) -> AVAudioSessionDataSourceDescription? {
    tryInitialize()
    return audioDataSourceMap[key]
  }

  private func add(camera: AVCaptureDevice, deviceId: CKDeviceID) -> [CKAdjustableCameraConfiguration] {
    let result: [CKAdjustableCameraConfiguration] = camera.formats.map { format in
      let conf = adjustableCameraConfiguration(device: camera, format: format)
      let key = CKAVMapperKey(deviceId: deviceId, configurationId: conf.id)
      formatMap[key] = format
      deviceMap[key] = camera
      reverseDeviceMap[camera] = key
      return conf
    }
    if !result.isEmpty {
      cameras[camera] = CKDevice(id: deviceId, configuration: result)
    }
    return result
  }

  private func add(cameras: [AVCaptureDevice], deviceId: CKDeviceID) -> CKDevice<[CKAdjustableCameraConfiguration]>? {
    let confs: [CKAdjustableCameraConfiguration] = cameras.flatMap { add(camera: $0, deviceId: deviceId) }
    return confs.isEmpty ? nil : CKDevice(id: deviceId, configuration: confs)
  }

  private func add(
    microphones: [AVAudioSessionPortDescription],
    deviceId: CKDeviceID
  ) -> CKDevice<[CKAdjustableMicrophoneConfiguration]> {
    var configurations = [CKAdjustableMicrophoneConfiguration]()
    if let microphone = microphones.first(where: { $0.portType == .builtInMic }) {
      configurations = (microphone.dataSources ?? []).flatMap { dataSource in
        return (dataSource.supportedPolarPatterns ?? []).map { polarPattern in
          let key = CKAVMapperKey(
            deviceId: deviceId,
            configurationId: CKDeviceConfigurationID(value: "\(dataSource.dataSourceID)_\(polarPattern.rawValue)")
          )
          audioInputMap[key] = microphone
          audioDataSourceMap[key] = dataSource
          return CKAdjustableMicrophoneConfiguration(
            id: key.configurationId,
            location: dataSource.orientation.ckDeviceLocation,
            polarPattern: polarPattern.ckPolarPattern
          )
        }
      }
    }
    configurations.append(
      CKAdjustableMicrophoneConfiguration(
        id: CKDeviceConfigurationID(value: "default"),
        location: .unspecified,
        polarPattern: .unspecified
      )
    )
    return CKDevice(id: deviceId, configuration: configurations)
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

  private var audioInputMap = [CKAVMapperKey: AVAudioSessionPortDescription]()
  private var audioDataSourceMap = [CKAVMapperKey: AVAudioSessionDataSourceDescription]()
  private var deviceMap = [CKAVMapperKey: AVCaptureDevice]()
  private var formatMap = [CKAVMapperKey: AVCaptureDevice.Format]()
  private var reverseDeviceMap = [AVCaptureDevice: CKAVMapperKey]()
  private var cameras = [AVCaptureDevice: CKDevice<[CKAdjustableCameraConfiguration]>]()
  private var initialized = false
  private var configuration: CKAdjustableConfiguration!

  private func tryInitialize() {
    guard !initialized else { return }
    initialized = true
    let backCamera = add(cameras: discovery.backCameras, deviceId: CKAVCamera.back.value)
    let frontCamera = add(cameras: discovery.frontCameras, deviceId: CKAVCamera.front.value)
    let microphone = add(microphones: discovery.audioInputs, deviceId: CKAVMicrophone.builtIn.value)
    let cameras = [backCamera, frontCamera].compactMap { $0 }.map { ($0.id, $0) }
    configuration = CKAdjustableConfiguration(
      cameras: Dictionary(uniqueKeysWithValues: cameras),
      microphone: microphone
    )
  }
}
