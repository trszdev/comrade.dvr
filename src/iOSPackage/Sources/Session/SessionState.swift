import ComposableArchitecture

public struct SessionState: Equatable {
}

public enum SessionAction {
  case toggleMicrophone
  case tapPreview
}

public struct SessionEnvironment {
}

public let sessionReducer = Reducer<SessionState, SessionAction, SessionEnvironment> { _, _, _ in .none }
