import SwiftUI

struct StartButtonView: View {
  let isBusy: Bool
  var isDisabled = false
  @Environment(\.theme) var theme: Theme
  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    GeometryReader { geometry in
      let backgroundColor = (isHovered || isBusy || isDisabled) ? theme.accentColorHover : theme.accentColor
      let foregroundColor = theme.startHeaderBackgroundColor
      ZStack {
        Rectangle().foregroundColor(foregroundColor)
        RoundedRectangle(cornerRadius: geometry.defaultCornerRadius).foregroundColor(backgroundColor)
        HStack {
          isBusy ?
            ActivityIndicator(isAnimating: true) { $0.color = UIColor(foregroundColor) } :
            nil
          Text(appLocale.startRecordingString)
            .foregroundColor(foregroundColor)
            .font(.title3)
            .minimumScaleFactor(0.5)
        }
      }
      .touchdownOverlay(isHovered: $isHovered)
      .defaultAnimation
      .allowsHitTesting(!isBusy && !isDisabled)
    }
  }

  @State private var isHovered = false
}

#if DEBUG

struct StartButtonViewPreview: PreviewProvider {
  static var previews: some View {
    StartButtonView(isBusy: false).previewLayout(.fixed(width: 300, height: 50))
    StartButtonView(isBusy: true).previewLayout(.fixed(width: 300, height: 50))
  }
}

#endif
