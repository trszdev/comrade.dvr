import SwiftUI

struct IdentifiableAnyView: View, Identifiable {
  let id = UUID()
  let view: AnyView

  var body: some View {
    view
  }
}

extension View {
  func eraseToAnyView() -> IdentifiableAnyView {
    IdentifiableAnyView(view: AnyView(self))
  }
}
