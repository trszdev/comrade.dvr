import AutocontainerKit

struct SettingsViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    registerSetting(container: container, LanguageSetting.self)
    registerSetting(container: container, ThemeSetting.self)
    registerSetting(container: container, AssetLimitSetting.self)
    registerSetting(container: container, AssetLengthSetting.self)
    container.singleton.autoregister(
      SettingsViewModel.self,
      construct: SettingsViewModelImpl.init(
        settingsContactUsCellViewBuilder:
        settingsAssetsLimitCellViewBuilder:
        settingsLanguageCellViewBuilder:
        settingsAssetLengthCellViewBuilder:
        settingsThemeCellViewBuilder:
      )
    )
    container.transient.autoregister(construct: SettingsView.Builder.init(viewModel:))
    container.transient.autoregister(construct: SettingsContactUsCellView.Builder.init(navigationViewPresenter:))
  }

  private func registerSetting<Value: SettingValue>(container: AKContainer, _ valueType: Value.Type) {
    container.singleton.autoregister(construct: SettingsCellViewModelImpl<Value>.init(setting:))
    container.transient.autoregister(
      construct: SettingsPickerCellViewBuilder<Value>.init(viewModel:tablePickerCellViewBuilder:)
    )
  }
}
