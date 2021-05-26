import SwiftUI

struct SettingsContactUsCellView: View {
  @Environment(\.locale) var locale: Locale

  var body: some View {
    SettingsCellView(text: locale.contactUsString, rightText: "help@comradedvr.app", sfSymbol: .contactUs)
  }
}
