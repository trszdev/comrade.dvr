import SwiftUI

struct SettingsUsedSpaceCellView: View {
  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    TableCellView(
      centerView: Text(appLocale.usedSpaceString).eraseToAnyView(),
      rightView: Text("1,2Gb").eraseToAnyView(),
      sfSymbol: .usedSpace,
      separator: [],
      isDisabled: true
    )
  }
}
