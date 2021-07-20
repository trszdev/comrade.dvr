import SwiftUI

struct SettingsClearAssetsCellView: View {
  struct Builder {
    let mediaChunkRepository: MediaChunkRepository

    func makeView() -> AnyView {
      SettingsClearAssetsCellView(clearAssets: mediaChunkRepository.deleteAllMediaChunks).eraseToAnyView()
    }
  }

  @Environment(\.appLocale) var appLocale: AppLocale
  var clearAssets: () -> Void = {}

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

  @State private var showAlert = false
}
