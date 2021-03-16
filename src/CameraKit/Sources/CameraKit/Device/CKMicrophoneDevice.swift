public protocol CKMicrophoneDevice {
  var device: CKDevice<CKCameraConfiguration> { get }
  var isMuted: Bool { get set }
}
