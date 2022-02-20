import Swinject
import SwinjectAutoregistration
import SwinjectExtensions

public enum SettingsAssembly: SharedAssembly {
  case shared

  public func assemble(container: Container) {
    container.autoregister(SettingsView.self, initializer: SettingsView.init)
    container.autoregister(SettingsRepository.self, initializer: SettingsUserDefaultsRepository.init(userDefaults:))
  }
}
