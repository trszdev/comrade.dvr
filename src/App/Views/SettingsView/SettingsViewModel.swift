import SwiftUI

protocol SettingsViewModel {
  var sections: [[AnyView]] { get }
}

#if DEBUG

struct PreviewSettingsViewModel: SettingsViewModel {
  var sections: [[AnyView]] {[
    [
      SettingsAssetsLimitCellView().eraseToAnyView(),
      SettingsAssetLengthCellView().eraseToAnyView(),
      SettingsUsedSpaceCellView().eraseToAnyView(),
      SettingsClearAssetsCellView().eraseToAnyView(),
    ],
    [
      SettingsLanguageCellView().eraseToAnyView(),
      SettingsThemeCellView().eraseToAnyView(),
    ],
    [
      SettingsContactUsCellView().eraseToAnyView(),
      SettingsRateAppCellView().eraseToAnyView(),
    ],
  ]}
}

#endif
