import SwiftUI

struct SettingsCellButtonView: View {
  @Environment(\.theme) var theme: Theme
  @Environment(\.safeAreaInsets) var safeAreaInsets: EdgeInsets
  let text: String

  var body: some View {
    let backgroundColor = isHovered ? theme.accentColorHover : theme.mainBackgroundColor
    HStack(spacing: 0) {
      HStack {
        Spacer()
        Text(text)
        Spacer()
      }
      .frame(maxHeight: .infinity)
      .padding(.trailing, safeAreaInsets.trailing)
      .border(width: 0.5, edges: [.top], color: theme.textColor)
    }
    .foregroundColor(theme.destructiveTextColor)
    .background(backgroundColor.ignoresSafeArea())
    .frame(height: 40)
    .defaultAnimation
    .onHoverGesture { isHovered in self.isHovered = isHovered }
  }

  @State private var isHovered = false
}

#if DEBUG

struct SettingsCellButtonViewPreview: PreviewProvider {
  static var previews: some View {
    SettingsCellButtonView(text: "Sample text")
      .environment(\.theme, DarkTheme())
  }
}

#endif
