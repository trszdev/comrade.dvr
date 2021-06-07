import AutocontainerKit

struct PreviewSettingsViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    registerSetting(container: container, LanguageSetting.self)
    registerSetting(container: container, ThemeSetting.self)
    registerSetting(container: container, AssetLimitSetting.self)
    registerSetting(container: container, AssetLengthSetting.self)
  }

  private func registerSetting<Value: Codable>(container: AKContainer, _ valueType: Value.Type) {
    container.singleton.autoregister(construct: { (setting: AnySetting<Value>) in
      SettingsCellViewModelImpl(setting: setting)
    })
  }
}

extension PreviewLocator {
  func settingsCellViewModel<Value: Codable>(_ type: Value.Type) -> SettingsCellViewModelImpl<Value> {
    locator.resolve(SettingsCellViewModelImpl<Value>.self)
  }
}
