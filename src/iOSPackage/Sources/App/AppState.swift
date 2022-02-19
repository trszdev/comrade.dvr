import ComposableArchitecture
import Settings
import ComposableArchitectureExtensions
import CommonUI

public struct AppState: Equatable {
  public var settingsState: SettingsState = .init()
}

public enum AppAction {
  case settingsAction(SettingsAction)
}

public struct AppEnvironment {
  public var routing: Routing = RoutingStub()
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  .init { _, action, environment in
    switch action {
    case .settingsAction(.contactUs):
      return .task { @MainActor in
        environment.routing.tabRouting?.selectMain()
      }
    case .settingsAction(.clearAllRecordings):
      return .task { @MainActor in
        environment.routing.tabRouting?.selectHistory()
      }
    default:
      break
    }
    return .none
  },

  settingsReducer.pullback(state: \.settingsState, action: /AppAction.settingsAction)
)
