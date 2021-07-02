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

final class CustomNavigationController: UINavigationController {
}
