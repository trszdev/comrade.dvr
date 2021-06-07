import SwiftUI

struct SettingsUsedSpaceCellView: View {
  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    SettingsCellView(
      text: appLocale.usedSpaceString,
      rightText: "1,2Gb",
      sfSymbol: .usedSpace,
      separator: [],
      isDisabled: true
    )
  }
}
