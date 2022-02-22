import ComposableArchitecture
import Settings
import ComposableArchitectureExtensions
import CommonUI
import History

public struct AppState: Equatable {
  public var settingsState: SettingsState = .init()
  public var historyState: HistoryState = .init()
}

public enum AppAction {
  case settingsAction(SettingsAction)
  case historyAction(HistoryAction)
}

public struct AppEnvironment {
  public var routing: Routing = RoutingStub()
  public var settingsRepository: SettingsRepository = SettingsRepositoryStub()
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  .init { _, action, environment in
    switch action {
    case .settingsAction(.contactUs):
      return .task {
        await environment.routing.tabRouting?.selectMain()
      }
    case .settingsAction(.clearAllRecordings):
      return .task {
        await environment.routing.tabRouting?.selectHistory()
      }
    default:
      break
    }
    return .none
  },

  settingsReducer.pullback(state: \.settingsState, action: /AppAction.settingsAction) {
    .init(repository: $0.settingsRepository)
  },

  historyReducer.pullback(state: \.historyState, action: /AppAction.historyAction) {
    .init(routing: $0.routing)
  }
)
