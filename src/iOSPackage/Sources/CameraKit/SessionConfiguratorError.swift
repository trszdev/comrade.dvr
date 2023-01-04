import Device

public enum SessionConfiguratorError: Error {
  case frontCamera(PartialKeyPath<CameraConfiguration>)
  case backCamera(PartialKeyPath<CameraConfiguration>)
  case microphone(PartialKeyPath<MicrophoneConfiguration>)
}
