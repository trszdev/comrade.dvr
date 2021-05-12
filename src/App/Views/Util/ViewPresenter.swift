import SwiftUI

protocol ViewPresenter {
  func presentView<Content: View>(animated: Bool, @ViewBuilder content: () -> Content)
}

extension ViewPresenter {
  func presentView<Content: View>(@ViewBuilder content: () -> Content) {
    presentView(animated: true, content: content)
  }
}
