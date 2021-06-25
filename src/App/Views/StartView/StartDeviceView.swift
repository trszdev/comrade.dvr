import SwiftUI

struct StartDeviceView: View {
  @Environment(\.theme) var theme: Theme
  let viewModel: StartViewModelDevice

  var body: some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      let accentColor = viewModel.isActive ? theme.accentColor : theme.disabledTextColor
      let backgroundColor = isHovered ? theme.accentColorHover : theme.mainBackgroundColor
      ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: width / 10)
          .foregroundColor(backgroundColor)
          .overlay(
            RoundBorder(hasSpaces: !viewModel.isActive)
              .stroke(lineWidth: 7)
              .foregroundColor(accentColor)
          )
        VStack(alignment: .leading, spacing: 3) {
          title(width: width).foregroundColor(accentColor)
          ScrollView {
            VStack(alignment: .leading) {
              ForEach(viewModel.details, id: \.self) { detail in
                detailText(width: width, detail)
                  .foregroundColor(viewModel.isActive ? theme.textColor : theme.disabledTextColor)
              }
            }
          }
          .allowsHitTesting(false)
        }
        .padding()
        VStack {
          Spacer()
          HStack {
            Spacer()
            icon(width: width).foregroundColor(accentColor).background(backgroundColor)
          }
        }
        .padding()
      }
    }
    .touchdownOverlay(isHovered: $isHovered)
    .defaultAnimation
    .aspectRatio(1, contentMode: .fill)
  }

  private func title(width: CGFloat) -> some View {
    Text(viewModel.name)
      .bold()
      .font(.system(size: max(min(width / 10, 20), 10) ))
      .lineLimit(2)
  }

  private func icon(width: CGFloat) -> some View {
    Text(Image(sfSymbol: viewModel.sfSymbol))
      .font(.system(size: max(min(width / 10, 20), 10) ))
      .padding(1)
  }

  private func detailText(width: CGFloat, _ detail: String) -> some View {
    Text(detail)
      .font(.system(size: max(min(width / 14, 15), 8) ))
      .lineLimit(1)
  }

  @State private var isHovered = false
}

private struct RoundBorder: Shape {
  var hasSpaces = true

  func path(in rect: CGRect) -> Path {
    var path = Path()

    let points = self.points(in: rect)
    if !hasSpaces {
      path.move(to: points[0].0)
    }
    for (pt1, pt2, corner, pt3, pt4) in points {
      if hasSpaces {
        path.move(to: pt1)
      } else {
        path.addLine(to: pt1)
      }
      path.addLine(to: pt2)
      path.addCurve(to: pt3, control1: corner, control2: corner)
      if hasSpaces {
        path.addLine(to: pt4)
      }
    }
    if !hasSpaces {
      path.addLine(to: points[0].0)
    }
    return path
  }

  // swiftlint:disable large_tuple
  private func points(in rect: CGRect) -> [(CGPoint, CGPoint, CGPoint, CGPoint, CGPoint)] {
    let sideLength = rect.width / 3
    let sideRemaining = rect.width - sideLength
    let length = rect.width / 6
    let remaining = rect.width - length
    let width = rect.width
    return  [
      (
        CGPoint(x: 0, y: sideLength),
        CGPoint(x: 0, y: length),
        CGPoint(x: 0, y: 0),
        CGPoint(x: length, y: 0),
        CGPoint(x: sideLength, y: 0)
      ),
      (
        CGPoint(x: sideRemaining, y: 0),
        CGPoint(x: remaining, y: 0),
        CGPoint(x: width, y: 0),
        CGPoint(x: width, y: length),
        CGPoint(x: width, y: sideLength)
      ),
      (
        CGPoint(x: width, y: sideRemaining),
        CGPoint(x: width, y: remaining),
        CGPoint(x: width, y: width),
        CGPoint(x: remaining, y: width),
        CGPoint(x: sideRemaining, y: width)
      ),
      (
        CGPoint(x: sideLength, y: width),
        CGPoint(x: length, y: width),
        CGPoint(x: 0, y: width),
        CGPoint(x: 0, y: remaining),
        CGPoint(x: 0, y: sideRemaining)
      ),
    ]
  }
}

#if DEBUG

struct StartDeviceViewPreview: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 0) {
      HStack {
        StartDeviceView(viewModel: viewModel).frame(width: 60, height: 60)
        StartDeviceView(viewModel: viewModel).frame(width: 100, height: 100)
        StartDeviceView(viewModel: viewModel).frame(width: 200, height: 200)
        StartDeviceView(viewModel: viewModel).frame(width: 300, height: 300)
      }
      .padding()
      HStack {
        StartDeviceView(viewModel: viewModel).frame(width: 60, height: 60)
        StartDeviceView(viewModel: viewModel).frame(width: 100, height: 100)
        StartDeviceView(viewModel: viewModel).frame(width: 200, height: 200)
        StartDeviceView(viewModel: viewModel).frame(width: 300, height: 300)
      }
      .padding()
      .environment(\.theme, DarkTheme())
    }
    .background(Color.green)
    .previewLayout(.fixed(width: 700, height: 650))
  }

  private static var viewModel: StartViewModelDevice {
    StartViewModelDevice(
      name: "Front camera",
      details: Array(1...20).map { String(repeating: String($0), count: 30) },
      sfSymbol: Bool.random() ? .camera : .mic,
      isActive: Bool.random()
    )
  }
}

#endif
