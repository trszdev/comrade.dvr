import CameraKit

struct UserDefaultsDevicesStore: DevicesStore {
  func store(device: Device) {
    notImplemented()
  }

  func loadStoredDevices() -> [Device] {
    notImplemented()
  }
}

private func store(device: Device) {
  fatalError()
}

private func loadStoredDevices() -> [Device] {
  fatalError()
}

private func mergeDevices(devices: [Device], adjustableConfiguration: CKAdjustableConfiguration) -> [Device] {
  fatalError()
}
