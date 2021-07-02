import AutocontainerKit

struct SettingsViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    registerSetting(container: container, LanguageSetting.self)
    registerSetting(container: container, ThemeSetting.self)
    registerSetting(container: container, AssetLimitSetting.self)
    registerSetting(container: container, AssetLengthSetting.self)
    registerSetting(container: container, OrientationSetting.self)
    container.singleton.autoregister(SettingsViewModel.self, construct: SettingsViewModelImpl.init)
    container.transient.autoregister(construct: SettingsView.Builder.init)
    container.transient.autoregister(construct: SettingsContactUsCellView.Builder.init)
    container.transient.autoregister(construct: SettingsRateAppCellView.Builder.init)
  }

  private func registerSetting<Value: SettingValue>(container: AKContainer, _ valueType: Value.Type) {
    container.singleton.autoregister(construct: SettingsCellViewModelImpl<Value>.init)
    container.transient.autoregister(construct: SettingsPickerCellViewBuilder<Value>.init)
  }
}
