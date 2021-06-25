import CameraKit

struct CameraDevice: Codable, Identifiable, Equatable {
  var isEnabled: Bool
  var id: CKDeviceID
  var adjustableConfiguration: CKUIAdjustableCameraConfiguration
  var configuration: CKCameraConfiguration
}
