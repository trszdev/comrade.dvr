import AutocontainerKit
import Foundation

struct SettingsAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    registerSetting(container: container, key: "app:lang", LanguageSetting.system)
    registerSetting(container: container, key: "app:theme", ThemeSetting.system)
    registerSetting(container: container, key: "app:assetLimit", AssetLimitSetting(value: .from(gigabytes: 5)))
    registerSetting(container: container, key: "app:assetLength", AssetLengthSetting(value: .from(minutes: 1)))
    registerSetting(container: container, key: "app:orientation", OrientationSetting.system)
    container.transient.autoregister(AppLocaleModel.self, construct: AppLocaleModelImpl.init)
  }

  private func registerSetting<Value: SettingValue>(container: AKContainer, key: String, _ value: Value) {
    container.singleton.autoregister(construct: { (locator: AKLocator) -> AnySetting<Value> in
      let userDefaults = locator.resolve(UserDefaults.self)!
      let userDefaultsSetting = UserDefaultsSetting(key: key, userDefaults: userDefaults, value: value)
      let setting = AnySetting(userDefaultsSetting)
      return setting
    })
  }
}
