import CameraKit

protocol DevicesStore {
  func store(devices: [Device])
  func loadStoredDevices() -> [Device]
}
