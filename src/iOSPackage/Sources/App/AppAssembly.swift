import Swinject
import Util
import Assets
import Combine
import Routing
import SwinjectExtensions
import ComposableArchitecture
import Settings
import CommonUI
import Device
import CameraKit

public enum AppAssembly: SharedAssembly {
  case shared

  public func assembleWithChildren(container: Container) -> [SharedAssembly] {
    container.registerStores()
    container.autoregister(
      AppEnvironment.self,
      initializer: AppEnvironment.init(
        routing:
        settingsRepository:
        permissionDialogPresenting:
        permissionChecker:
        sessionConfigurator:
        deviceConfigurationRepository:
      )
    )
    container.registerSingleton(AppCoordinator.self) { resolver in
      .init(
        router: resolver.resolve(Router.self)!,
        deviceConfigurationRepositoryFactory: .init(resolver.resolve(DeviceConfigurationRepository.self)!),
        appearancePublisher: resolver.resolve(CurrentValuePublisher<Appearance?>.self)!,
        settingsRepositoryFactory: .init(resolver.resolve(SettingsRepository.self)!),
        viewStoreFactory: .init(resolver.resolve(ViewStore<AppState, AppAction>.self)!)
      )
    }
    container.registerInstance(UserDefaults.standard)
    return [CameraKitAssembly.shared, RoutingAssembly.shared, DeviceAssembly.shared]
  }
}

private extension Container {
  func registerStores() {
    registerSingleton(Store<AppState, AppAction>.self) { resolver in
      Store(initialState: AppState(), reducer: appReducer, environment: resolver.resolve(AppEnvironment.self)!)
    }
    register(ViewStore<AppState, AppAction>.self) { resolver in
      ViewStore(resolver.resolve(Store<AppState, AppAction>.self)!)
    }
    registerStore(state: \.settingsState, action: AppAction.settingsAction)
    registerStore(state: \.historyState, action: AppAction.historyAction)
    registerStore(state: \.startState.selectedCameraState, action: { AppAction.startAction(.deviceCameraAction($0)) })
    registerStore(state: \.startState.microphoneState, action: { AppAction.startAction(.deviceMicrophoneAction($0)) })
    registerStore(state: \.startState, action: AppAction.startAction)
    registerStore(state: \.paywallState, action: AppAction.paywallAction)
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
