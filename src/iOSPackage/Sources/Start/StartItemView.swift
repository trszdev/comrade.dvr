import SwiftUI

struct StartItemView<Content: View>: View {
  let action: () -> Void
  let enabled: Bool
  let color: Color
  @ViewBuilder var summaryContent: () -> Content

  var body: some View {
    Button(action: action) {
      RoundBorder(hasSpaces: !enabled)
        .stroke(lineWidth: 10)
        .padding(5)
        .foregroundColor(color)
        .overlay(summaryContent())
    }
    .aspectRatio(1, contentMode: .fit)
    .animation(.default, value: color)
    .animation(.default, value: enabled)
  }
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
    return [
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
