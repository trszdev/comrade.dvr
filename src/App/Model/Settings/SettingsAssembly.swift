import AutocontainerKit
import Foundation

struct SettingsAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    registerSetting(container: container, key: "app:lang", LanguageSetting.system)
    registerSetting(container: container, key: "app:theme", ThemeSetting.system)
    registerSetting(container: container, key: "app:assetLimit", AssetLimitSetting(value: .from(gigabytes: 5)))
    registerSetting(container: container, key: "app:assetLength", AssetLengthSetting(value: .from(minutes: 1)))
  }

  private func registerSetting<Value: SettingValue>(container: AKContainer, key: String, _ value: Value) {
    let userDefaultsSetting = UserDefaultsSetting(key: key, userDefaults: .standard, value: value)
    let setting = AnySetting(userDefaultsSetting)
    container.singleton.autoregister(value: setting)
  }
}
