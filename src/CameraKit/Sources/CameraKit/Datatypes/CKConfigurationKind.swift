public protocol CKConfigurationKind {
  associatedtype CameraConfiguration: Hashable
  associatedtype MicrophoneConfiguration: Hashable
  var cameras: [CKDeviceID: CKDevice<CameraConfiguration>] { get }
  var microphone: CKDevice<MicrophoneConfiguration>? { get }
}
