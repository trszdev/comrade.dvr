import SwiftUI

struct SettingsRestoreCellView: View {
  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    TableCellView(
      centerView: Text(appLocale.restoreDefaultSettingsString).eraseToAnyView(),
      rightView: EmptyView().eraseToAnyView(),
      sfSymbol: .restore
    )
    .onTapGesture {
      showAlert = true
    }
    .alert(isPresented: $showAlert, content: {
      Alert(
        title: Text(appLocale.warningString),
        message: Text(appLocale.restoreDefaultSettingsAskString),
        primaryButton: .cancel(),
        secondaryButton: .destructive(Text(appLocale.restoreDefaultSettingsConfirmString), action: restoreDefaults)
      )
    })
  }

  private func restoreDefaults() {

  }

  @State private var showAlert = false
}
