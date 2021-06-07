import SwiftUI

protocol SettingsViewModel {
  var sections: [[AnyView]] { get }
}

#if DEBUG

struct PreviewSettingsViewModel: SettingsViewModel {
  var sections: [[AnyView]] {[
    [
      settingsAssetsLimitCellView.eraseToAnyView(),
      settingsAssetLengthCellView.eraseToAnyView(),
      SettingsUsedSpaceCellView().eraseToAnyView(),
      SettingsClearAssetsCellView().eraseToAnyView(),
    ],
    [
      settingsLanguageCellView.eraseToAnyView(),
      settingsThemeCellView.eraseToAnyView(),
    ],
    [
      SettingsContactUsCellView(
        viewPresenter: PreviewLocator.default.locator.resolve(UINavigationController.self)
      )
      .eraseToAnyView(),
      SettingsRateAppCellView().eraseToAnyView(),
    ],
  ]}

  private var settingsAssetsLimitCellView: some View {
    let availableOptions: [Int?] = [1, 5, 10, 20, 30, nil]
    return SettingsPickerCellView(
      viewModel: PreviewLocator.default.settingsCellViewModel(AssetLimitSetting.self),
      viewPresenter: ModalViewPresenter(),
      title: { $0.assetsLimitString },
      rightText: { $0.assetSize($1.value) },
      sfSymbol: .assetLimit,
      availableOptions: availableOptions
        .map { $0.flatMap(FileSize.from(gigabytes:)) }
        .map(AssetLimitSetting.init(value:))
    )
  }

  private var settingsLanguageCellView: some View {
    SettingsPickerCellView(
      viewModel: PreviewLocator.default.settingsCellViewModel(LanguageSetting.self),
      viewPresenter: ModalViewPresenter(),
      title: { $0.languageString },
      rightText: { $0.languageName($1) },
      sfSymbol: .language,
      availableOptions: LanguageSetting.allCases
    )
  }

  private var settingsAssetLengthCellView: some View {
    SettingsPickerCellView(
      viewModel: PreviewLocator.default.settingsCellViewModel(AssetLengthSetting.self),
      viewPresenter: ModalViewPresenter(),
      title: { $0.assetLengthString },
      rightText: { $0.assetDuration($1.value) },
      sfSymbol: .assetLength,
      availableOptions: [1, 5, 10].map(Double.init).map { AssetLengthSetting(value: .from(minutes: $0)) }
    )
  }

  private var settingsThemeCellView: some View {
    SettingsPickerCellView(
      viewModel: PreviewLocator.default.settingsCellViewModel(ThemeSetting.self),
      viewPresenter: ModalViewPresenter(),
      title: { $0.themeString },
      rightText: { $0.themeName($1) },
      sfSymbol: .theme,
      availableOptions: ThemeSetting.allCases
    )
  }
}

#endif
