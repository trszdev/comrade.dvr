public enum StartStateError: Error, Hashable, Identifiable {
  case unexpectedError(String)
  case microphoneRuntimeError
  case frontCameraRuntimeError
  case backCameraRuntimeError

  public var id: Int {
    switch self {
    case .microphoneRuntimeError:
      return 0
    case .frontCameraRuntimeError:
      return 1
    case .backCameraRuntimeError:
      return 2
    case .unexpectedError(let string):
      return 3 + string.hash
    }
  }
}
