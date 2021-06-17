import SwiftUI

struct StartButtonView: View {
  @Environment(\.theme) var theme: Theme
  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    GeometryReader { geometry in
      let backgroundColor = isHovered ? theme.accentColorHover : theme.accentColor
      ZStack {
        Rectangle().foregroundColor(theme.startHeaderBackgroundColor)
        RoundedRectangle(cornerRadius: geometry.defaultCornerRadius).foregroundColor(backgroundColor)
        Text(appLocale.startRecordingString)
          .foregroundColor(theme.startHeaderBackgroundColor)
          .font(.title3)
          .minimumScaleFactor(0.5)
      }
      .touchdownOverlay(isHovered: $isHovered)
      .defaultAnimation
    }
  }

  @State private var isHovered = false
}

#if DEBUG

struct StartButtonViewPreview: PreviewProvider {
  static var previews: some View {
    StartButtonView()
      .previewLayout(.fixed(width: 300, height: 50))
  }
}

#endif
