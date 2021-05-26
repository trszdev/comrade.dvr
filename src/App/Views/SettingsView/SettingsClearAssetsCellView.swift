import SwiftUI

struct SettingsClearAssetsCellView: View {
  @Environment(\.locale) var locale: Locale

  var body: some View {
    SettingsCellButtonView(text: locale.clearAssetsString)
  }
}
