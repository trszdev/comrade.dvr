import SwiftUI

struct TableCellView: View {
  @Environment(\.theme) var theme: Theme
  @Environment(\.geometry) var geometry: Geometry
  let centerView: AnyView
  let rightView: AnyView
  let sfSymbol: SFSymbol
  var separator = [Edge.bottom]
  var isDisabled = false

  var body: some View {
    let backgroundColor = isHovered ? theme.accentColorHover : theme.mainBackgroundColor
    let textColor = isDisabled ? theme.disabledTextColor : theme.textColor
    HStack(spacing: 0) {
      Image(sfSymbol: sfSymbol).frame(width: 40)
        .frame(maxHeight: .infinity)
        .padding(.leading, geometry.safeAreaInsets.leading)
        .foregroundColor(textColor)
        .touchdownOverlay(isHovered: $isHovered)
      HStack {
        centerView.touchdownOverlay(isHovered: $isHovered)
        Spacer()
        rightView
      }
      .animation(nil)
      .frame(maxHeight: .infinity)
      .padding(.trailing, geometry.safeAreaInsets.trailing + 15)
      .border(width: 0.5, edges: separator, color: theme.textColor)
      .foregroundColor(textColor)
    }
    .background(backgroundColor.ignoresSafeArea().touchdownOverlay(isHovered: $isHovered))
    .frame(height: 40)
    .allowsHitTesting(!isDisabled)
    .defaultAnimation
  }

  @State private var isHovered = false
}

#if DEBUG

struct TableCellViewPreview: PreviewProvider {
  static var previews: some View {
    let cell = TableCellView(
      centerView: Text("Sample text").eraseToAnyView(),
      rightView: Text("Yes").eraseToAnyView(),
      sfSymbol: .play
    )
    let disabledCell = TableCellView(
      centerView: Text("Sample text").eraseToAnyView(),
      rightView: Text("Yes").eraseToAnyView(),
      sfSymbol: .play,
      isDisabled: true
    )
    VStack {
      cell
      cell.environment(\.theme, DarkTheme())
      disabledCell
      disabledCell.environment(\.theme, DarkTheme())
    }
    .padding()
    .background(Color.gray)
  }
}

#endif
