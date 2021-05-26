import SwiftUI

extension View {
  func onHoverGesture(hoverGesture: @escaping (Bool) -> Void) -> some View {
    gesture(HoverGesture.from(hoverGesture: hoverGesture))
  }

  func onHoverGesture(_ binding: Binding<Bool>) -> some View {
    onHoverGesture { isHovered in binding.wrappedValue = isHovered }
  }
}
