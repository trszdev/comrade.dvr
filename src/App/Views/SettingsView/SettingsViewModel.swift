import SwiftUI
import AutocontainerKit

protocol SettingsViewModel {
  var sections: [[AnyView]] { get }
}

final class SettingsViewModelImpl: AKBuilder, SettingsViewModel {
  var sections: [[AnyView]] {[
    [
      settingsAssetsLimitCellView,
      settingsAssetLengthCellView,
      resolve(SettingsUsedSpaceCellViewBuilder.self).makeView(),
      settingsOrientationCellView,
    ],
    [
      settingsLanguageCellView,
      settingsThemeCellView,
    ],
    [
      // TODO: SettingsRestoreCellView().eraseToAnyView(),
      resolve(SettingsContactUsCellView.Builder.self).makeView().eraseToAnyView(),
      resolve(SettingsRateAppCellView.Builder.self).makeView().eraseToAnyView(),
      resolve(SettingsClearAssetsCellView.Builder.self).makeView(),
    ],
  ]}

  private var settingsOrientationCellView: AnyView {
    resolve(SettingsPickerCellViewBuilder<OrientationSetting>.self).makeView(
      title: { $0.orientationString },
      rightText: { $0.orientation($1) },
      sfSymbol: .orientation,
      availableOptions: OrientationSetting.allCases,
      separator: []
    )
  }

  private var settingsAssetsLimitCellView: AnyView {
    let availableOptions: [Int?] = [1, 5, 10, 20, 30, nil]
    return resolve(SettingsPickerCellViewBuilder<AssetLimitSetting>.self).makeView(
      title: { $0.assetsLimitString },
      rightText: { $0.assetSize($1.value) },
      sfSymbol: .assetLimit,
      availableOptions: availableOptions
        .map { $0.flatMap(FileSize.from(gigabytes:)) }
        .map(AssetLimitSetting.init)
    )
  }

  private var settingsLanguageCellView: AnyView {
    resolve(SettingsPickerCellViewBuilder<LanguageSetting>.self).makeView(
      title: { $0.languageString },
      rightText: { $0.languageName($1) },
      sfSymbol: .language,
      availableOptions: LanguageSetting.allCases
    )
  }

  private var settingsAssetLengthCellView: AnyView {
    resolve(SettingsPickerCellViewBuilder<AssetLengthSetting>.self).makeView(
      title: { $0.assetLengthString },
      rightText: { $0.assetDuration($1.value) },
      sfSymbol: .assetLength,
      availableOptions: [1, 2, 3, 5, 10].map(Double.init).map { AssetLengthSetting(value: .from(minutes: $0)) }
    )
  }

  private var settingsThemeCellView: AnyView {
    resolve(SettingsPickerCellViewBuilder<ThemeSetting>.self).makeView(
      title: { $0.themeString },
      rightText: { $0.themeName($1) },
      sfSymbol: .theme,
      availableOptions: ThemeSetting.allCases,
      separator: []
    )
  }
}
