import SwiftUI

protocol NavigationViewPresenter: ViewPresenter {
  func popViewController()
}

extension UINavigationController: NavigationViewPresenter {
  func presentView<Content: View>(animated: Bool, @ViewBuilder content: () -> Content) {
    let hostingVc = UIHostingController(rootView: content())
    pushViewController(hostingVc, animated: animated)
  }

  func presentViewController(animated: Bool, viewController: UIViewController) {
    pushViewController(viewController, animated: animated)
  }

  func popViewController() {
    popViewController(animated: true)
  }
}
