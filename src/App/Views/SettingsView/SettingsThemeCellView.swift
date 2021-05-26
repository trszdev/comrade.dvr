import SwiftUI

struct SettingsThemeCellView: View {
  @Environment(\.locale) var locale: Locale

  var body: some View {
    SettingsCellView(text: locale.themeString, rightText: "System", sfSymbol: .theme, isLast: true)
  }
}
