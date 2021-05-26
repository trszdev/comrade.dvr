import SwiftUI

struct SettingsAssetLengthCellView: View {
  @Environment(\.locale) var locale: Locale

  var body: some View {
    SettingsCellView(text: locale.assetLengthString, rightText: "5min", sfSymbol: .assetLength)
  }
}
