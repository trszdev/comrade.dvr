import SwiftUI

struct StartDeviceView: View {
  @Environment(\.theme) var theme: Theme
  @State var device: StartViewModelDevice
  let onTap: () -> Void

  var body: some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: geometry.defaultCornerRadius)
          .fill(isHovered ? theme.accentColorHover : theme.mainBackgroundColor)
          .defaultAnimation
        RoundedRectangle(cornerRadius: geometry.defaultCornerRadius)
          .strokeBorder(style: StrokeStyle(lineWidth: 7))
          .foregroundColor(theme.accentColor)
        VStack(alignment: .leading) {
          Text(device.name)
            .bold()
            .font(.title2)
            .foregroundColor(theme.accentColor)
            .lineLimit(1)
          ForEach(device.details, id: \.self) { detailsText in
            Text(detailsText)
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
    .aspectRatio(1, contentMode: .fill)
  }

  @State private var isHovered = false
}

struct StartDeviceAddView: View {
  @Environment(\.theme) var theme: Theme
  let onTap: () -> Void

  var body: some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      let backgroundColor = isHovered ? theme.accentColorHover : theme.mainBackgroundColor
      ZStack {
        RoundedRectangle(cornerRadius: geometry.defaultCornerRadius)
          .fill(backgroundColor)
        RoundedRectangle(cornerRadius: geometry.defaultCornerRadius)
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
    .defaultAnimation
    .onTapGesture(perform: onTap)
    .simultaneousGesture(HoverGesture.from { isHovered in self.isHovered = isHovered })
    .aspectRatio(1, contentMode: .fill)
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
        device: StartViewModelDevice(
          name: "Front camera",
          details: ["1920x1080", "30fps", "30kbit/s"]
        ),
        onTap: {}
      )
      .background(Color.pink).previewLayout(layout)
      StartDeviceAddView(onTap: {}).background(Color.pink).previewLayout(layout)
    }.environment(\.theme, DarkTheme())
  }
}

#endif
