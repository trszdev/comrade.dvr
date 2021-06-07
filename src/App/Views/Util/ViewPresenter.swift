import SwiftUI

protocol ViewPresenter {
  func presentView<Content: View>(animated: Bool, @ViewBuilder content: @escaping () -> Content)
  func presentViewController(animated: Bool, viewController: UIViewController)
}

extension ViewPresenter {
  func presentView<Content: View>(@ViewBuilder content: @escaping () -> Content) {
    presentView(animated: true, content: content)
  }

  func presentViewController(viewController: UIViewController) {
    presentViewController(animated: true, viewController: viewController)
  }
}
