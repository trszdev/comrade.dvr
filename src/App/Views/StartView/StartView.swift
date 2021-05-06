import SwiftUI

struct StartView: View {
  @Environment(\.theme) var theme: Theme

  let items = (1...20).map(String.init(describing:))

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        theme.mainBackgroundColor
        VStack(spacing: 0) {
          CustomScrollView(isVertical: true) {
            devicesView()
          }
          startHeaderView()
            .padding(.bottom, geometry.safeAreaInsets.bottom)
            .padding(.leading, geometry.safeAreaInsets.leading)
            .padding(.trailing, geometry.safeAreaInsets.trailing)
            .background(theme.startHeaderBackgroundColor)
        }
      }.ignoresSafeArea()
    }
  }

  func devicesView() -> some View {
    let columns = [GridItem(.adaptive(minimum: 100, maximum: 200), spacing: 10)]
    return LazyVGrid(columns: columns, alignment: .center) {
      ForEach(items, id: \.self) { value in
        if Bool.random() {
          StartDeviceAddView(onTap: { print("Tap add") })
            .aspectRatio(1, contentMode: .fill)
        } else {
          StartDeviceView(
            onTap: { print("Tap add2") },
            titleText: "Camera \(value)",
            detailsText: ["HD", "60fps"]
          )
          .aspectRatio(1, contentMode: .fill)
        }
      }
    }
    .padding(10)
  }

  func startHeaderView() -> some View {
    VStack(spacing: 10) {
      HStack(spacing: 10) {
        theme.startIcon
        VStack(alignment: .leading) {
          Text("ComradeDVR v1.0.0").foregroundColor(theme.textColor).font(.caption2)
          Text("Last capture: 10.12.2021 15:00").foregroundColor(theme.textColor).font(.caption2)
          Text("Last update: 10.03.2021 14:88").foregroundColor(theme.textColor).font(.caption2)
          Text("Used space: 100mb / 10gb [100%]").foregroundColor(theme.textColor).font(.caption2)
        }
        Spacer()
      }
      StartButtonView().frame(maxHeight: 50)
    }
    .padding(10)
  }
}

private extension GeometryProxy {
  var itemSize: CGFloat {
    max(min(size.width - 40, size.height - 40) / 3, 10)
  }
}

#if DEBUG

struct StartViewPreview: PreviewProvider {
  static var previews: some View {
    StartView().environment(\.theme, DarkTheme())
  }
}

#endif
