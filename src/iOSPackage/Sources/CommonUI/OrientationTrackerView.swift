import SwiftUI

struct UIInterfaceOrientationTrackerView: UIViewControllerRepresentable {
  var orientationDidChange: (UIInterfaceOrientation) -> Void

  func makeUIViewController(context: Context) -> ViewController {
    let viewController = ViewController()
    viewController.orientationDidChange = orientationDidChange
    return viewController
  }

  func updateUIViewController(_ uiViewController: ViewController, context: Context) {
  }

  final class ViewController: UIViewController {
    var orientationDidChange: (UIInterfaceOrientation) -> Void = { _ in }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      sendOrientation()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
      super.viewWillTransition(to: size, with: coordinator)
      coordinator.animate(alongsideTransition: nil) { [weak self] _ in
        self?.sendOrientation()
      }
    }

    private func sendOrientation() {
      guard let orientation = view.window?.windowScene?.interfaceOrientation else { return }
      orientationDidChange(orientation)
    }
  }
}
