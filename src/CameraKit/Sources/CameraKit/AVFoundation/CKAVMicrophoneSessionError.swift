import Foundation

public enum CKAVMicrophoneSessionError: Error {
  case cantConfigureSession(inner: Error)
  case cantSetInputOrientation(inner: Error)
  case unknownRecordingError
  case recordingError(inner: Error)
  case failedToFinish
}

extension CKAVMicrophoneSessionError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case let .cantConfigureSession(error):
      return "Can't configure session (\(error.localizedDescription))"
    case let .cantSetInputOrientation(error):
      return "Can't configure session (\(error.localizedDescription))"
    case .unknownRecordingError:
      return "Unknown recording error"
    case let .recordingError(error):
      return "Recording error (\(error.localizedDescription))"
    case .failedToFinish:
      return "Failed to finish"
    }
  }
}
