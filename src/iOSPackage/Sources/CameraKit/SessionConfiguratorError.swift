import Device

public enum SessionConfiguratorError: Error {
  public enum CameraError: Error {
    case fields(fields: [PartialKeyPath<CameraConfiguration>])
    case connectionError
  }

  public enum MicrophoneError: Error {
    case fields(fields: [PartialKeyPath<MicrophoneConfiguration>])
    case runtimeError
  }

  case camera(front: CameraError?, back: CameraError?)
  case microphone(MicrophoneError)

  static func camera(isFront: Bool, _ error: CameraError) -> Self {
    isFront ? .camera(front: error, back: nil) : .camera(front: nil, back: error)
  }
}
