import AutocontainerKit
import UIKit

struct PreviewMainViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.singleton.autoregister(UINavigationController.self, construct: CustomNavigationController.init)
  }
}

private final class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {
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
