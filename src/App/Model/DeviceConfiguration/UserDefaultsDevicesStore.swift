import CameraKit
import Foundation

struct UserDefaultsDevicesStore: DevicesStore {
  let ckManager: CKManager
  let userDefaults: UserDefaults

  func store(devices: [Device]) {
    DispatchQueue.global(qos: .background).async { [userDefaults] in
      guard let jsonData = try? devices.jsonData() else { return }
      userDefaults.set(jsonData, forKey: key)
    }
  }

  func loadStoredDevices() -> [Device] {
    var devices = loadCurrentDevicesOrdered()
    var storedDevices = loadDevicesFromDefaults()
    var result = [Device]()
    while !devices.isEmpty, !storedDevices.isEmpty {
      guard devices[0].id == storedDevices[0].id else { break }
      let storedDevice = storedDevices.removeFirst()
      let device = devices.removeFirst()
      switch (storedDevice, device) {
      case (.camera(var storedCameraDevice), .camera(let cameraDevice)):
        storedCameraDevice.adjustableConfiguration = cameraDevice.adjustableConfiguration
        result.append(.camera(device: storedCameraDevice))
      case (.microphone(var storedMicrophoneDevice), .microphone(let microphoneDevice)):
        storedMicrophoneDevice.adjustableConfiguration = microphoneDevice.adjustableConfiguration
        result.append(.microphone(device: storedMicrophoneDevice))
      default:
        break
      }
    }
    result.append(contentsOf: devices)
    let nearest = findNeareastDevices(desiredDevices: result)
    return nearest
  }

  private func loadCurrentDevicesOrdered() -> [Device] {
    var devices = loadCurrentDevices()
    let desiredIds = [CKAVCamera.back.value, CKAVCamera.front.value, CKAVMicrophone.builtIn.value]
    var result = [Device]()
    for desiredId in desiredIds {
      guard let device = devices[desiredId] else { continue }
      devices.removeValue(forKey: desiredId)
      result.append(device)
    }
    for device in devices.values {
      result.append(device)
    }
    return result
  }

  private func loadCurrentDevices() -> [CKDeviceID: Device] {
    let uiConfiguration = ckManager.adjustableConfiguration.ui
    var devices = [CKDeviceID: Device]()
    for (id, adjustableConfiguration) in uiConfiguration.cameras.mapValues(\.configuration) {
      let cameraDevice = CameraDevice(
        isEnabled: id == CKAVCamera.back.value,
        id: id, adjustableConfiguration: adjustableConfiguration,
        configuration: desiredCameraConfiguration
      )
      devices[id] = .camera(device: cameraDevice)
    }
    if let uiMicrophone = uiConfiguration.microphone {
      let microphoneDevice = MicrophoneDevice(
        isEnabled: false,
        id: uiMicrophone.id,
        adjustableConfiguration: uiMicrophone.configuration,
        configuration: desiredMicrophoneConfiguration
      )
      devices[microphoneDevice.id] = .microphone(device: microphoneDevice)
    }
    return devices
  }

  private func findNeareastDevices(desiredDevices: [Device]) -> [Device] {
    var cameras = Set<CKDevice<CKCameraConfiguration>>()
    var cameraDevices = [CKDeviceID: CameraDevice]()
    var microphoneDevices = [CKDeviceID: MicrophoneDevice]()
    var microphone: CKDevice<CKMicrophoneConfiguration>?
    for desiredDevice in desiredDevices {
      switch desiredDevice {
      case var .camera(cameraDevice):
        let isEnabled = cameraDevice.isEnabled
        cameraDevice.isEnabled = false
        cameraDevices[cameraDevice.id] = cameraDevice
        guard isEnabled else { continue }
        cameras.insert(CKDevice(id: cameraDevice.id, configuration: cameraDevice.configuration))
      case var .microphone(microphoneDevice):
        let isEnabled = microphoneDevice.isEnabled
        microphoneDevice.isEnabled = false
        microphoneDevices[microphoneDevice.id] = microphoneDevice
        guard isEnabled else { continue }
        microphone = CKDevice(id: microphoneDevice.id, configuration: microphoneDevice.configuration)
      }
    }
    let requestedConfiguration = CKConfiguration(cameras: cameras, microphone: microphone)
    let nearestConfiguration = ckManager.configurationPicker.nearestConfiguration(for: requestedConfiguration)
    for (id, configuration) in nearestConfiguration.cameras.mapValues(\.configuration) {
      cameraDevices[id]?.isEnabled = true
      cameraDevices[id]?.configuration = configuration
    }
    if let microphone = nearestConfiguration.microphone {
      microphoneDevices[microphone.id]?.isEnabled = true
      microphoneDevices[microphone.id]?.configuration = microphone.configuration
    }
    return desiredDevices.map(\.id).compactMap { id in
      if let cameraDevice = cameraDevices[id] {
        return .camera(device: cameraDevice)
      } else if let microphoneDevice = microphoneDevices[id] {
        return .microphone(device: microphoneDevice)
      }
      return nil
    }
  }

  private func loadDevicesFromDefaults() -> [Device] {
    guard let data = userDefaults.data(forKey: key),
      let devices = try? data.decodeJson([Device].self)
    else {
      return []
    }
    return devices
  }
}

private var desiredCameraConfiguration: CKCameraConfiguration {
  CKCameraConfiguration(
    size: CKSize(width: 1920, height: 1080),
    zoom: 1.0,
    fps: 30,
    fieldOfView: 100,
    orientation: .portrait,
    autoFocus: .contrastDetection,
    stabilizationMode: .auto,
    videoGravity: .resizeAspectFill,
    videoQuality: .high,
    useH265: true,
    bitrate: CKBitrate(bitsPerSecond: 15_000_000)
  )
}

private var desiredMicrophoneConfiguration: CKMicrophoneConfiguration {
  CKMicrophoneConfiguration(
    orientation: .portrait,
    location: .unspecified,
    polarPattern: .stereo,
    duckOthers: false,
    useSpeaker: false,
    useBluetoothCompatibilityMode: false,
    audioQuality: .high
  )
}

private let key = "app:stored_devices"
