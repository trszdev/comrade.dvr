import SwiftUI
import StoreKit

struct SettingsRateAppCellView: View {
  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    SettingsCellView(text: appLocale.rateAppString, sfSymbol: .star, separator: [], onTap: {
      let scenes = UIApplication.shared.connectedScenes
      guard let scene = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
        return
      }
      SKStoreReviewController.requestReview(in: scene)
    })
  }
}
