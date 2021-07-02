public protocol CKMicrophoneDevice: AnyObject {
  var device: CKDevice<CKMicrophoneConfiguration> { get }
  var isMuted: Bool { get set }
}
