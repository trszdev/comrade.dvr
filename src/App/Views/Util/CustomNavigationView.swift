import SwiftUI

struct CustomNavigationViewBuilder {
  let navigationViewController: UINavigationController

  func makeView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> AnyView {
    CustomNavigationView(navigationViewController: navigationViewController, content: content).eraseToAnyView()
  }
}

struct CustomNavigationView<Content: View>: UIViewControllerRepresentable {
  let navigationViewController: UINavigationController
  @ViewBuilder let content: () -> Content

  func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
  }

  func makeUIViewController(context: Context) -> UINavigationController {
    navigationViewController.presentView(animated: false, content: content)
    return navigationViewController
  }
}

final class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {
  init() {
    super.init(navigationBarClass: nil, toolbarClass: nil)
    delegate = self
    isNavigationBarHidden = true
  }

  required init?(coder aDecoder: NSCoder) {
    notImplemented()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tryHideNavigationBar()
  }

  func navigationController(
    _ navigationController: UINavigationController,
    willShow viewController: UIViewController,
    animated: Bool
  ) {
    tryHideNavigationBar()
  }

  private func tryHideNavigationBar() {
    guard viewControllers.count < 2 else { return }
    setNavigationBarHidden(true, animated: false)
  }
}
