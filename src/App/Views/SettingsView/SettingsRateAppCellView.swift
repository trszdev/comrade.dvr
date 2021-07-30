import SwiftUI
import StoreKit

struct SettingsRateAppCellView: View {
  struct Builder {
    let application: UIApplication

    func makeView() -> SettingsRateAppCellView {
      SettingsRateAppCellView(application: application)
    }
  }

  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    TableCellView(
      centerView: Text(appLocale.rateAppString).eraseToAnyView(),
      rightView: EmptyView().eraseToAnyView(),
      sfSymbol: .star,
      separator: []
    )
    .onTapGesture {
      let scenes = application.connectedScenes
      guard let scene = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
        return
      }
      SKStoreReviewController.requestReview(in: scene)
    }
    .accessibility(.settingsRateUsButton)
  }

  let application: UIApplication
}
