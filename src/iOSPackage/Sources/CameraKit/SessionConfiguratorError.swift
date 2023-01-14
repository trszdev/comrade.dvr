import Device

public enum SessionConfiguratorCameraError: Error {
  case fields(fields: [PartialKeyPath<CameraConfiguration>])
  case connectionError
}

public enum SessionConfiguratorMicrophoneError: Error {
  case fields(fields: [PartialKeyPath<MicrophoneConfiguration>])
  case runtimeError
}
