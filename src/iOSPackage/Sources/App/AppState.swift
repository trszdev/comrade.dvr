import ComposableArchitecture

public struct AppState: Equatable {
}

public enum AppAction {
}

public let appReducer = Reducer<AppState, AppAction, Void>.combine(
  .init { _, _, _ in
  .none
  }
)
