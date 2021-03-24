public protocol CKMicrophoneDevice {
  var device: CKDevice<CKMicrophoneConfiguration> { get }
  var isMuted: Bool { get set }
}
