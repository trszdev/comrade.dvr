import SwiftUI

extension View {
  func touchdownOverlay(callback: @escaping TouchDownView.TouchDownCallback) -> some View {
    overlay(TouchDownView(callback: callback))
  }

  func touchdownOverlay(callback: @escaping (_ isEnded: Bool) -> Void) -> some View {
    overlay(TouchDownView(callback: callback))
  }

  func touchdownOverlay(isHovered: Binding<Bool>) -> some View {
    overlay(TouchDownView { isEnded in isHovered.wrappedValue = !isEnded })
  }
}
