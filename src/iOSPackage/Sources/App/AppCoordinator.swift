import ComposableArchitecture
import CommonUI
import Util
import UIKit
import Combine
import Assets
import Settings
import Routing
import Device
import CameraKit
import AVFoundation

@MainActor
public final class AppCoordinator {
  public var window: UIWindow?

  public nonisolated init(
    router: Router,
    deviceConfigurationRepositoryFactory: Factory<DeviceConfigurationRepository>,
    appearancePublisher: CurrentValuePublisher<Appearance?>,
    settingsRepositoryFactory: Factory<SettingsRepository>,
    viewStoreFactory: Factory<ViewStore<AppState, AppAction>>,
    indexer: DeviceConfigurationIndexer
  ) {
    self.router = router
    self.deviceConfigurationRepositoryFactory = deviceConfigurationRepositoryFactory
    self.appearancePublisher = appearancePublisher
    self.settingsRepositoryFactory = settingsRepositoryFactory
    self.viewStoreFactory = viewStoreFactory
    self.indexer = indexer
  }

  public func loadAndStart() async {
    router.window = window
    await router.selectLoading(animated: false)
    let settingsRepository = settingsRepositoryFactory.make()
    let deviceConfigurationRepository = deviceConfigurationRepositoryFactory.make()
    cancellable = appearancePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak window] appearance in
        window?.overrideUserInterfaceStyle = appearance.interfaceStyle
      }
    let settings = await settingsRepository.load()
    let index = await indexer.makeIndex()
    let deviceConfiguration: Device.DeviceConfiguration
    if let loadedConfig = await deviceConfigurationRepository.load() {
      deviceConfiguration = loadedConfig
    } else {
      deviceConfiguration = indexer.makeDefaultConfig(index: index)
    }
    let viewStore = viewStoreFactory.make()
    viewStore.send(.settingsAction(.settingsLoaded(settings)))
    viewStore.send(.startAction(.deviceConfigurationLoaded(deviceConfiguration, index)))
    if viewStore.isPremium, settings.autoStart != false {
      viewStore.send(.startAction(.autostart))
    }
    await Task.wait(.seconds(0.1))
    await router.selectTab(animated: true)
    do {
      try AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
    } catch {
      log.warn("failed setAllowHapticsAndSystemSoundsDuringRecording")
      log.warn(error: error)
    }
  }

  private let router: Router
  private let deviceConfigurationRepositoryFactory: Factory<DeviceConfigurationRepository>
  private var settingsRepositoryFactory: Factory<SettingsRepository>
  private var viewStoreFactory: Factory<ViewStore<AppState, AppAction>>
  private let appearancePublisher: CurrentValuePublisher<Appearance?>
  private var cancellable: AnyCancellable?
  private let indexer: DeviceConfigurationIndexer
}
