import SwiftUI

struct SettingsCellView: View {
  @Environment(\.theme) var theme: Theme
  @Environment(\.geometry) var geometry: Geometry
  let text: String
  var rightText = ""
  let sfSymbol: SFSymbol
  var separator = [Edge.bottom]
  var isDisabled = false
  var onTap: () -> Void = {}

  var body: some View {
    let backgroundColor = isHovered ? theme.accentColorHover : theme.mainBackgroundColor
    HStack(spacing: 0) {
      Image(sfSymbol: sfSymbol).frame(width: 40)
        .frame(maxHeight: .infinity)
        .padding(.leading, geometry.safeAreaInsets.leading)
        .foregroundColor(theme.textColor)
      HStack {
        Text(text)
        Spacer()
        Text(rightText)
      }
      .animation(nil)
      .frame(maxHeight: .infinity)
      .padding(.trailing, geometry.safeAreaInsets.trailing + 15)
      .border(width: 0.5, edges: separator, color: theme.textColor)
      .foregroundColor(isDisabled ? theme.disabledTextColor : theme.textColor)
    }
    .background(backgroundColor.ignoresSafeArea())
    .frame(height: 40)
    .if(!isDisabled) { view in
      view
        .defaultAnimation
        .onTapGesture(perform: onTap)
        .simultaneousGesture(HoverGesture.bind($isHovered))
    }
  }

  func with(onTap: @escaping () -> Void) -> SettingsCellView {
    SettingsCellView(text: text, sfSymbol: sfSymbol, separator: separator, isDisabled: isDisabled, onTap: onTap)
  }

  @State private var isHovered = false
}

#if DEBUG

struct SettingsCellViewPreview: PreviewProvider {
  static var previews: some View {
    SettingsCellView(text: "Sample text", rightText: "yes", sfSymbol: .play)
      .environment(\.theme, DarkTheme())
  }
}

#endif
