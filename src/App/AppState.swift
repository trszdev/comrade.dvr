import ComposableArchitecture

struct AppState: Equatable {
}

enum AppAction {
}

let appReducer = Reducer<AppState, AppAction, Void>.combine(
  .init { _, _, _ in
    .none
  }
)
