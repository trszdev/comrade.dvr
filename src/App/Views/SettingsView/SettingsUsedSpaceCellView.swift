import SwiftUI

struct SettingsUsedSpaceCellView: View {
  @Environment(\.locale) var locale: Locale

  var body: some View {
    SettingsCellView(
      text: locale.usedSpaceString,
      rightText: "1,2Gb",
      sfSymbol: .usedSpace,
      isLast: true,
      isDisabled: true
    )
  }
}
