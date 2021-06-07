import SwiftUI

struct HistoryMenuView: View {
  @Environment(\.theme) var theme: Theme
  @Environment(\.geometry) var geometry: Geometry
  let title: String
  let subtitle: String

  var body: some View {
    let isLittle = geometry.size.height < 500
    let height = CGFloat(isLittle ? 33 : 50)
    let padding = CGFloat(isLittle ? 5 : 11)
    let horizontalPadding = CGFloat(isLittle ? 4 : 0)
    let textScale = CGFloat(isLittle ? 0.85 : 1)
    return HStack {
      HistoryMenuButtonView(sfSymbol: .calendar).padding(padding).frame(height: height)
      Spacer()
      VStack {
        Text(title)
          .lineLimit(1)
          .font(.title3)
          .foregroundColor(theme.textColor)
        Text(subtitle)
          .lineLimit(1)
          .font(.footnote)
          .foregroundColor(theme.accentColor)
      }
      .scaleEffect(textScale)
      .frame(height: height)
      Spacer()
      HistoryMenuButtonView(sfSymbol: .selectDevice).padding(padding).frame(height: height)
    }
    .padding(.horizontal, horizontalPadding)
    .background(theme.mainBackgroundColor)
  }
}

private struct HistoryMenuButtonView: View {
  @Environment(\.theme) var theme: Theme
  let sfSymbol: SFSymbol

  var body: some View {
    let color = isHovered ? theme.accentColorHover : theme.accentColor
    let view = Image(sfSymbol: sfSymbol).fitResizable.foregroundColor(color)
    return Rectangle()
      .foregroundColor(color)
      .defaultAnimation
      .mask(view)
      .simultaneousGesture(HoverGesture.bind($isHovered))
      .aspectRatio(contentMode: .fit)
      .background(view)
  }

  @State private var isHovered = false
}

#if DEBUG

struct HistoryMenuViewPreviews: PreviewProvider {
  static var previews: some View {
    let smallGeometry = Geometry(size: CGSize(width: 0, height: 200), safeAreaInsets: EdgeInsets())
    VStack {
      HistoryMenuView(title: "Title", subtitle: "Subtitle")
      HistoryMenuView(title: "Title", subtitle: "Subtitle").environment(\.theme, DarkTheme())
      Spacer().frame(height: 100)
      VStack {
        HistoryMenuView(title: "Title", subtitle: "Subtitle")
        HistoryMenuView(title: "Title", subtitle: "Subtitle").environment(\.theme, DarkTheme())
      }
      .environment(\.geometry, smallGeometry)
    }
  }
}

#endif
