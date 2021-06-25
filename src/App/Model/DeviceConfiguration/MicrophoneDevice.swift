import CameraKit

struct MicrophoneDevice: Codable, Identifiable, Equatable {
  var isEnabled: Bool
  var id: CKDeviceID
  var adjustableConfiguration: CKUIAdjustableMicrophoneConfiguration
  var configuration: CKMicrophoneConfiguration
}
