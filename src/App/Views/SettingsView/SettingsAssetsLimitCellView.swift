import SwiftUI

struct SettingsAssetsLimitCellView: View {
  @Environment(\.locale) var locale: Locale

  var body: some View {
    SettingsCellView(text: locale.assetsLimitString, rightText: "10Gb", sfSymbol: .assetLimit)
  }
}
