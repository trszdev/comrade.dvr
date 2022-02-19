import Swinject
import Util
import Assets
import Combine
import Routing
import SwinjectExtensions
import ComposableArchitecture
import Settings

public enum AppAssembly: SharedAssembly {
  case shared

  public func assembleWithChildren(container: Container) -> [SharedAssembly] {
    container.registerSingleton(Store<AppState, AppAction>.self) { resolver in
      Store(initialState: AppState(), reducer: appReducer, environment: resolver.resolve(AppEnvironment.self)!)
    }
    container.autoregister(AppEnvironment.self, initializer: AppEnvironment.init(routing:))
    container.registerStore(state: \.settingsState, action: AppAction.settingsAction)
    container
      .autoregister(AppCoordinator.self, initializer: AppCoordinator.init)
      .inObjectScope(.container)
    container
      .register(CurrentValuePublisher<Language?>.self) { resolver in
        resolver.resolve(ViewStore<SettingsState, SettingsAction>.self)!.currentValuePublisher(\.language)
      }
      .inObjectScope(.container)
    container
      .register(CurrentValuePublisher<Appearance?>.self) { resolver in
        resolver.resolve(ViewStore<SettingsState, SettingsAction>.self)!.currentValuePublisher(\.appearance)
      }
      .inObjectScope(.container)
    container.autoregister(TabBarViewController.self, initializer: TabBarViewController.init)
    return [RoutingAssembly.shared]
  }
}

extension Container {
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
