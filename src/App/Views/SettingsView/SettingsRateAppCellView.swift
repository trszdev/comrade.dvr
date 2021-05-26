import SwiftUI

struct SettingsRateAppCellView: View {
  @Environment(\.locale) var locale: Locale

  var body: some View {
    SettingsCellView(text: locale.rateAppString, sfSymbol: .star, isLast: true)
  }
}
