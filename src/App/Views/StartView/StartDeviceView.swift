import SwiftUI

struct StartDeviceView: View {
  let onTap: () -> Void
  @Environment(\.theme) var theme: Theme
  @State var titleText: String
  @State var detailsText: [String]

  var body: some View {
    return GeometryReader { geometry in
      let width = geometry.size.width
      let cornerRadius = width / 10

      ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(isHovered ? theme.accentColorHover : theme.mainBackgroundColor)
          .animation(.easeInOut)
        RoundedRectangle(cornerRadius: cornerRadius)
          .strokeBorder(style: StrokeStyle(lineWidth: 7))
          .foregroundColor(theme.accentColor)
        VStack(alignment: .leading) {
          Text(titleText)
            .bold()
            .font(.title2)
            .foregroundColor(theme.accentColor)
            .lineLimit(1)
          ForEach(0..<detailsText.count) { index in
            Text(detailsText[index])
              .font(.footnote)
              .foregroundColor(theme.textColor)
              .minimumScaleFactor(0.15)
          }
        }
        .padding(width < 100 ? 10 : 20)
        .minimumScaleFactor(0.65)
        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
      }
    }
    .onTapGesture(perform: onTap)
    .simultaneousGesture(HoverGesture.from { isHovered in self.isHovered = isHovered })
  }

  @State private var isHovered = false
}

struct StartDeviceAddView: View {
  let onTap: () -> Void
  @Environment(\.theme) var theme: Theme

  var body: some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      let cornerRadius = width / 10
      let backgroundColor = isHovered ? theme.accentColorHover : theme.mainBackgroundColor
      ZStack {
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(backgroundColor)
        RoundedRectangle(cornerRadius: cornerRadius)
          .strokeBorder(style: StrokeStyle(lineWidth: 7))
          .foregroundColor(theme.textColor)
        Rectangle()
          .fill(backgroundColor)
          .frame(width: width, height: width / 3)
        Rectangle()
          .fill(backgroundColor)
          .frame(width: width / 3, height: width)
        Image(sfSymbol: .plus)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(maxWidth: 80)
          .padding(width < 100 ? 10 : 20)
          .foregroundColor(theme.textColor)
      }
    }
    .animation(.easeIn(duration: 0.25))
    .onTapGesture(perform: onTap)
    .simultaneousGesture(HoverGesture.from { isHovered in self.isHovered = isHovered })
  }

  @State private var isHovered = false
}

#if DEBUG

struct StartDeviceViewPreview: PreviewProvider {
  static var previews: some View {
    let previewLayouts: [PreviewLayout] = [
      .fixed(width: 60, height: 60),
      .fixed(width: 100, height: 100),
      .fixed(width: 200, height: 200),
    ]
    ForEach(0..<previewLayouts.count) { index in
      let layout = previewLayouts[index]
      StartDeviceView(
        onTap: {},
        titleText: "Front camera",
        detailsText: ["1920x1080", "30fps", "30kbit/s"]
      )
      .background(Color.pink).previewLayout(layout)
      StartDeviceAddView(onTap: {}).background(Color.pink).previewLayout(layout)
    }.environment(\.theme, DarkTheme())
  }
}

#endif
