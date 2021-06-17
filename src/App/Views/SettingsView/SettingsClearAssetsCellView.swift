import SwiftUI

struct SettingsClearAssetsCellView: View {
  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    SettingsCellButtonView(text: appLocale.clearAssetsString)
      .onTapGesture {
        showAlert = true
      }
      .alert(isPresented: $showAlert, content: {
        Alert(
          title: Text(appLocale.warningString),
          message: Text(appLocale.clearAllAssetsAskString),
          primaryButton: .cancel(),
          secondaryButton: .destructive(Text(appLocale.clearAllAssetsConfirmString), action: clearAssets)
        )
      })
  }

  private func clearAssets() {

  }

  @State private var showAlert = false
}
