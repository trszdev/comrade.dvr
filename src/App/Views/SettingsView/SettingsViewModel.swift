import SwiftUI

protocol SettingsViewModel {
  var sections: [[AnyView]] { get }
}

struct SettingsViewModelImpl: SettingsViewModel {
  let settingsContactUsCellViewBuilder: SettingsContactUsCellView.Builder
  let settingsAssetsLimitCellViewBuilder: SettingsPickerCellViewBuilder<AssetLimitSetting>
  let settingsLanguageCellViewBuilder: SettingsPickerCellViewBuilder<LanguageSetting>
  let settingsAssetLengthCellViewBuilder: SettingsPickerCellViewBuilder<AssetLengthSetting>
  let settingsThemeCellViewBuilder: SettingsPickerCellViewBuilder<ThemeSetting>

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
      settingsContactUsCellViewBuilder.makeView().eraseToAnyView(),
      SettingsRateAppCellView().eraseToAnyView(),
    ],
  ]}

  private var settingsAssetsLimitCellView: some View {
    let availableOptions: [Int?] = [1, 5, 10, 20, 30, nil]
    return settingsAssetsLimitCellViewBuilder.makeView(
      title: { $0.assetsLimitString },
      rightText: { $0.assetSize($1.value) },
      sfSymbol: .assetLimit,
      availableOptions: availableOptions
        .map { $0.flatMap(FileSize.from(gigabytes:)) }
        .map(AssetLimitSetting.init(value:))
    )
  }

  private var settingsLanguageCellView: some View {
    settingsLanguageCellViewBuilder.makeView(
      title: { $0.languageString },
      rightText: { $0.languageName($1) },
      sfSymbol: .language,
      availableOptions: LanguageSetting.allCases
    )
  }

  private var settingsAssetLengthCellView: some View {
    settingsAssetLengthCellViewBuilder.makeView(
      title: { $0.assetLengthString },
      rightText: { $0.assetDuration($1.value) },
      sfSymbol: .assetLength,
      availableOptions: [1, 2, 3, 5, 10].map(Double.init).map { AssetLengthSetting(value: .from(minutes: $0)) }
    )
  }

  private var settingsThemeCellView: some View {
    settingsThemeCellViewBuilder.makeView(
      title: { $0.themeString },
      rightText: { $0.themeName($1) },
      sfSymbol: .theme,
      availableOptions: ThemeSetting.allCases
    )
  }
}
