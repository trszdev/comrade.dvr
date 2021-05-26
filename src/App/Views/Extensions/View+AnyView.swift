import SwiftUI

extension View {
  func eraseToAnyView() -> AnyView {
    AnyView(self)
  }
}

extension Array where Element: View {
  func eraseToAnyView() -> [AnyView] {
    map { $0.eraseToAnyView() }
  }
}
