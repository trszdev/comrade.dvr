import SwiftUI

struct EdgeBorder: Shape {
  let width: CGFloat
  let edges: [Edge]

  func path(in rect: CGRect) -> Path {
    var path = Path()
    for edge in edges {
      let line = CGRect(
        x: x(edge: edge, rect: rect),
        y: y(edge: edge, rect: rect),
        width: width(edge: edge, rect: rect),
        height: height(edge: edge, rect: rect)
      )
      path.addPath(Path(line))
    }
    return path
  }

  private func x(edge: Edge, rect: CGRect) -> CGFloat {
    switch edge {
    case .top, .bottom, .leading: return rect.minX
    case .trailing: return rect.maxX - width
    }
  }

  private func y(edge: Edge, rect: CGRect) -> CGFloat {
    switch edge {
    case .top, .leading, .trailing: return rect.minY
    case .bottom: return rect.maxY - width
    }
  }

  private func width(edge: Edge, rect: CGRect) -> CGFloat {
    switch edge {
    case .top, .bottom: return rect.width
    case .leading, .trailing: return self.width
    }
  }

  private func height(edge: Edge, rect: CGRect) -> CGFloat {
    switch edge {
    case .top, .bottom: return self.width
    case .leading, .trailing: return rect.height
    }
  }
}
