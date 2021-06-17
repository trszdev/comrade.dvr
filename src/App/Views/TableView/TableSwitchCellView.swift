import SwiftUI

struct TableSwitchCellView: View {
  @Environment(\.theme) var theme: Theme
  @Binding var isOn: Bool
  let sfSymbol: SFSymbol
  let text: String
  var separator = [Edge.bottom]
  var isDisabled = false

  var body: some View {
    TableCellView(
      centerView: Text(text).eraseToAnyView(),
      rightView: CustomSwitch(isOn: $isOn, isEnabled: !isDisabled).eraseToAnyView(),
      sfSymbol: sfSymbol,
      separator: separator,
      isDisabled: isDisabled
    )
    .onTapGesture {
      isOn.toggle()
    }
  }
}

#if DEBUG

struct TableSwitchCellViewPreview: PreviewProvider {
  static var previews: some View {
    VStack {
      TableSwitchCellView(isOn: .constant(true), sfSymbol: .play, text: "Play")
      TableSwitchCellView(isOn: .constant(true), sfSymbol: .play, text: "Play")
        .environment(\.theme, DarkTheme())
      TableSwitchCellView(isOn: .constant(false), sfSymbol: .play, text: "Play", isDisabled: true)
      TableSwitchCellView(isOn: .constant(false), sfSymbol: .play, text: "Play", isDisabled: true)
        .environment(\.theme, DarkTheme())
    }
    .padding()
    .background(Color.gray)
  }
}

#endif
