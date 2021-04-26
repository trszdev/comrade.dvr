import Combine

public protocol CKSession {
  var startupInfo: CKSessionStartupInfo { get }
  var outputPublisher: AnyPublisher<CKMediaChunk, Error> { get }
  var pressureLevelPublisher: AnyPublisher<CKPressureLevel, Never> { get }
  var cameras: [CKDeviceID: CKCameraDevice] { get }
  var microphone: CKMicrophoneDevice? { get }
  var configuration: CKConfiguration { get }
  func requestMediaChunk()
  var pressureLevel: CKPressureLevel { get }
}
