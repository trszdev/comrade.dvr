import CoreMedia

public protocol CKSessionPlugin {
  func didStart(session: CKSession)
  func didStop(session: CKSession)
  func didOutput(sampleBuffer: CMSampleBuffer, camera: CKDevice<CKCameraConfiguration>)
  func didOutput(sampleBuffer: CMSampleBuffer, microphone: CKDevice<CKMicrophoneConfiguration>)
}

public extension CKSessionPlugin {
  func didStart(session: CKSession) {}
  func didStop(session: CKSession) {}
  func didOutput(sampleBuffer: CMSampleBuffer, camera: CKDevice<CKCameraConfiguration>) {}
  func didOutput(sampleBuffer: CMSampleBuffer, microphone: CKDevice<CKMicrophoneConfiguration>) {}
}
