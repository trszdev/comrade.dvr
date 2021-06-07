import SwiftUI

struct SettingsClearAssetsCellView: View {
  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    SettingsCellButtonView(text: appLocale.clearAssetsString)
  }
}
