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
          title: Text(appLocale.clearAssetsString),
          message: Text("Are you sure?"),
          primaryButton: .cancel(),
          secondaryButton: .destructive(Text("Yes I'm sure"), action: clearAssets))
      })
  }

  private func clearAssets() {

  }

  @State private var showAlert = false
}
