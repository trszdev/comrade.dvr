import SwiftUI

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
