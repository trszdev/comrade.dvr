import CameraKit

struct Device: Identifiable, Codable {
  let isEnabled: Bool
  let id: CKDeviceID
  let configuration: DeviceConfiguration
}
