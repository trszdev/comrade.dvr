public protocol CKSession: AnyObject {
  var startupInfo: CKSessionStartupInfo { get }
  var delegate: CKSessionDelegate? { get set }
  var cameras: [CKDeviceID: CKCameraDevice] { get }
  var microphone: CKMicrophoneDevice? { get }
  var configuration: CKConfiguration { get }
  func requestMediaChunk()
  var pressureLevel: CKPressureLevel { get }
}
