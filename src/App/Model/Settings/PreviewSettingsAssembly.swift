import AutocontainerKit
import Foundation

struct PreviewSettingsAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    registerSetting(container: container, LanguageSetting.system)
    registerSetting(container: container, ThemeSetting.system)
    registerSetting(container: container, AssetLimitSetting(value: .from(gigabytes: 10)))
    registerSetting(container: container, AssetLengthSetting(value: .from(minutes: 1)))
    registerSetting(container: container, OrientationSetting.system)
    container.transient.autoregister(AppLocaleModel.self, construct: AppLocaleModelImpl.init)
  }

  private func registerSetting<Value: SettingValue>(container: AKContainer, _ value: Value) {
    let setting = AnySetting(TempSetting(value: value))
    container.singleton.autoregister(value: setting)
  }
}
