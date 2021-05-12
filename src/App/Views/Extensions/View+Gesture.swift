import SwiftUI

extension View {
  func onHoverGesture(hoverGesture: @escaping (Bool) -> Void) -> some View {
    gesture(HoverGesture.from(hoverGesture: hoverGesture))
  }
}
