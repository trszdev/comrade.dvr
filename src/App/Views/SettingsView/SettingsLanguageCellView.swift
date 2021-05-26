import SwiftUI

struct SettingsLanguageCellView: View {
  @Environment(\.locale) var locale: Locale

  var body: some View {
    SettingsCellView(text: locale.languageString, rightText: "System", sfSymbol: .language)
  }
}
