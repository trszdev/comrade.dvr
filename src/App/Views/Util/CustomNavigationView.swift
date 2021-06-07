import SwiftUI

struct CustomNavigationView<Content: View>: UIViewControllerRepresentable {
  @ViewBuilder let content: () -> Content

  func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
  }

  func makeUIViewController(context: Context) -> UINavigationController {
    let navigationViewController = PreviewLocator.default.locator.resolve(UINavigationController.self)!
    navigationViewController.presentView(animated: false, content: content)
    return navigationViewController
  }
}
