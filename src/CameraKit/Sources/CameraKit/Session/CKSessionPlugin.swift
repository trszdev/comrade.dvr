import CoreMedia

public protocol CKSessionPlugin {
  func setup(session: CKSession)
  func didOutput(sampleBuffer: CMSampleBuffer, camera: CKDevice<CKCameraConfiguration>)
  func didOutput(sampleBuffer: CMSampleBuffer, microphone: CKDevice<CKMicrophoneConfiguration>)
}
