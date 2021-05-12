import SwiftUI

struct SettingsCellView: View {
  @Environment(\.theme) var theme: Theme
  @Environment(\.safeAreaInsets) var safeAreaInsets: EdgeInsets
  let text: String
  var rightText = ""
  let sfSymbol: SFSymbol
  var isLast = false
  var isDisabled = false

  var body: some View {
    let backgroundColor = isHovered ? theme.accentColorHover : theme.mainBackgroundColor
    HStack(spacing: 0) {
      Image(sfSymbol: sfSymbol).frame(width: 40)
        .frame(maxHeight: .infinity)
        .padding(.leading, safeAreaInsets.leading)
        .foregroundColor(theme.textColor)
      HStack {
        Text(text)
        Spacer()
        Text(rightText)
      }
      .frame(maxHeight: .infinity)
      .padding(.trailing, safeAreaInsets.trailing + 15)
      .border(width: isLast ? 0 : 0.5, edges: [.bottom], color: theme.textColor)
      .foregroundColor(isDisabled ? theme.disabledTextColor : theme.textColor)
    }
    .background(backgroundColor.ignoresSafeArea())
    .frame(height: 40)
    .if(!isDisabled) { view in
      view
        .defaultAnimation
        .onHoverGesture { isHovered in self.isHovered = isHovered }
    }
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
