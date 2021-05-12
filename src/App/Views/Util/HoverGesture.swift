import SwiftUI

struct HoverGesture: Gesture {
  let onHover: (Bool) -> Void

  var body: some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { _ in self.onHover(true) }
      .onEnded { _ in self.onHover(false) }
  }

  static func from(hoverGesture: @escaping (Bool) -> Void) -> some Gesture {
    HoverGesture(onHover: hoverGesture)
  }
}
