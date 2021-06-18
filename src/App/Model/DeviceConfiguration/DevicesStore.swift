import CameraKit

protocol DevicesStore {
  func store(device: Device)
  func loadStoredDevices() -> [Device]
}
