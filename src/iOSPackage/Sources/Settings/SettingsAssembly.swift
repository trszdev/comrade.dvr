import Swinject
import SwinjectAutoregistration
import SwinjectExtensions
import Assets
import Util
import ComposableArchitecture
import ComposableArchitectureExtensions

public enum SettingsAssembly: SharedAssembly {
  case shared

  public func assemble(container: Container) {
    container.autoregister(SettingsView.self, initializer: SettingsView.init)
    container.autoregister(SettingsRepository.self, initializer: SettingsUserDefaultsRepository.init(userDefaults:))
    container.registerSingleton(CurrentValuePublisher<Language?>.self) { resolver in
      resolver.resolve(ViewStore<SettingsState, SettingsAction>.self)!.currentValuePublisher(\.settings.language)
    }
    container.registerSingleton(CurrentValuePublisher<Appearance?>.self) { resolver in
      resolver.resolve(ViewStore<SettingsState, SettingsAction>.self)!.currentValuePublisher(\.settings.appearance)
    }
  }
}
