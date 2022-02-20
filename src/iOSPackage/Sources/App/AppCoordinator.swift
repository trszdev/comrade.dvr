import ComposableArchitecture
import CommonUI
import Util
import UIKit
import Combine
import Assets
import Settings

@MainActor
public final class AppCoordinator {
  public var window: UIWindow?

  public nonisolated init(
    routing: Routing,
    appearancePublisher: CurrentValuePublisher<Appearance?>,
    settingsRepositoryFactory: Factory<SettingsRepository>,
    settingsViewStoreFactory: Factory<ViewStore<SettingsState, SettingsAction>>
  ) {
    self.routing = routing
    self.appearancePublisher = appearancePublisher
    self.settingsRepositoryFactory = settingsRepositoryFactory
    self.settingsViewStoreFactory = settingsViewStoreFactory
  }

  public func loadAndStart() async {
    window?.rootViewController = routing.viewController
    await routing.selectLoading(animated: false)
    let settingsRepository = settingsRepositoryFactory.make()
    appearancePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak window] appearance in
        window?.overrideUserInterfaceStyle = appearance.interfaceStyle
      }
      .store(in: &cancellables)
    let settings = await settingsRepository.load()
    let viewStore = settingsViewStoreFactory.make()
    viewStore.send(.settingsLoaded(settings))
    await Task.wait(.seconds(0.1))
    await routing.selectTab(animated: true)
  }

  private let routing: Routing
  private var settingsRepositoryFactory: Factory<SettingsRepository>
  private var settingsViewStoreFactory: Factory<ViewStore<SettingsState, SettingsAction>>
  private let appearancePublisher: CurrentValuePublisher<Appearance?>
  private var cancellables = Set<AnyCancellable>()
}
