import SwiftUI

struct MyButtonStyle: ButtonStyle {
  let theme: Theme

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .padding()
      .foregroundColor(theme.mainBackgroundColor)
      .background(configuration.isPressed ? theme.accentColorHover : theme.accentColor)
      .cornerRadius(8.0)
  }
}

struct StartButtonView: View {
  @Environment(\.theme) var theme: Theme

  var body: some View {
    GeometryReader { geometry in
      let cornerRadius = min(geometry.size.width, geometry.size.height) / 10
      let backgroundColor = isHovered ? theme.accentColorHover : theme.accentColor
      ZStack {
        Rectangle().foregroundColor(theme.startHeaderBackgroundColor)
        RoundedRectangle(cornerRadius: cornerRadius).foregroundColor(backgroundColor)
        Text("Hello world")
          .foregroundColor(theme.startHeaderBackgroundColor)
          .font(.title3)
          .minimumScaleFactor(0.5)
      }
      .onHoverGesture { isHovered in self.isHovered = isHovered }
      .animation(.easeIn(duration: 0.25))
    }
  }

  @State private var isHovered = false
}

#if DEBUG

struct StartButtonViewPreview: PreviewProvider {
  static var previews: some View {
    StartButtonView()
      .previewLayout(.fixed(width: 300, height: 50))
      .background(WhiteTheme().startHeaderBackgroundColor)
      .environment(\.theme, DarkTheme())
  }
}

#endif
