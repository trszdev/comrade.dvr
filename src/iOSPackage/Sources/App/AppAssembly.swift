import Swinject
import Util
import Assets
import Combine
import Routing
import SwinjectExtensions
import ComposableArchitecture
import Settings
import CommonUI

public enum AppAssembly: SharedAssembly {
  case shared

  public func assembleWithChildren(container: Container) -> [SharedAssembly] {
    container.registerStores()
    container.autoregister(AppEnvironment.self, initializer: AppEnvironment.init(routing:settingsRepository:))
    container.registerSingleton(AppCoordinator.self) { resolver in
      .init(
        routing: resolver.resolve(Routing.self)!,
        appearancePublisher: resolver.resolve(CurrentValuePublisher<Appearance?>.self)!,
        settingsRepositoryFactory: .init(resolver.resolve(SettingsRepository.self)!),
        settingsViewStoreFactory: .init(resolver.resolve(ViewStore<SettingsState, SettingsAction>.self)!)
      )
    }
    container.registerInstance(UserDefaults.standard)
    return [RoutingAssembly.shared]
  }
}

private extension Container {
  func registerStores() {
    registerSingleton(Store<AppState, AppAction>.self) { resolver in
      Store(initialState: AppState(), reducer: appReducer, environment: resolver.resolve(AppEnvironment.self)!)
    }
    registerStore(state: \.settingsState, action: AppAction.settingsAction)
    registerStore(state: \.historyState, action: AppAction.historyAction)
  }

  func registerStore<LocalState: Equatable, LocalAction>(
    state toLocalState: @escaping (AppState) -> LocalState,
    action fromLocalAction: @escaping (LocalAction) -> AppAction
  ) {
    register(Store<LocalState, LocalAction>.self) { resolver in
      resolver
        .resolve(Store<AppState, AppAction>.self)!
        .scope(state: toLocalState, action: fromLocalAction)
    }
    register(ViewStore<LocalState, LocalAction>.self) { resolver in
      ViewStore(resolver.resolve(Store<LocalState, LocalAction>.self)!)
    }
  }
}
