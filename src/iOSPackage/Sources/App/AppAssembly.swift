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
    container.registerSingleton(Store<AppState, AppAction>.self) { resolver in
      Store(initialState: AppState(), reducer: appReducer, environment: resolver.resolve(AppEnvironment.self)!)
    }
    container.autoregister(AppEnvironment.self, initializer: AppEnvironment.init(routing:settingsRepository:))
    container.registerStore(state: \.settingsState, action: AppAction.settingsAction)
    container
      .register(AppCoordinator.self) { resolver in
        .init(
          routing: resolver.resolve(Routing.self)!,
          appearancePublisher: resolver.resolve(CurrentValuePublisher<Appearance?>.self)!,
          settingsRepositoryFactory: .init(resolver.resolve(SettingsRepository.self)!),
          settingsViewStoreFactory: .init(resolver.resolve(ViewStore<SettingsState, SettingsAction>.self)!)
        )
      }
      .inObjectScope(.container)
    container
      .register(CurrentValuePublisher<Language?>.self) { resolver in
        resolver.resolve(ViewStore<SettingsState, SettingsAction>.self)!.currentValuePublisher(\.settings.language)
      }
      .inObjectScope(.container)
    container
      .register(CurrentValuePublisher<Appearance?>.self) { resolver in
        resolver.resolve(ViewStore<SettingsState, SettingsAction>.self)!.currentValuePublisher(\.settings.appearance)
      }
      .inObjectScope(.container)
    container.registerInstance(UserDefaults.standard)
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
