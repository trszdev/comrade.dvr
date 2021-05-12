import SwiftUI

extension GeometryProxy {
  var defaultCornerRadius: CGFloat {
    min(size.width, size.height) / 10
  }
}
