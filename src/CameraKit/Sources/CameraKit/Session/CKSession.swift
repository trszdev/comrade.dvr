public protocol CKSession {
  var cameras: [CKDeviceID: CKCameraDevice] { get }
  var microphone: CKMicrophoneDevice? { get }
  var configuration: CKConfiguration { get }
  var isRunning: Bool { get set }
  var pressureLevel: CKPressureLevel { get }
  var plugins: [CKSessionPlugin] { get set }
}
