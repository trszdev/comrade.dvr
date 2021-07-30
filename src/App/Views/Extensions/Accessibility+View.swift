import SwiftUI
import Accessibility

extension View {
  func accessibility(_ value: Accessibility) -> some View {
    accessibilityIdentifier(value.rawValue)
  }
}
