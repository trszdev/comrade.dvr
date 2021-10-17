import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
  var isAnimating: Bool
  var configuration = { (_: UIActivityIndicatorView) in }

  func makeUIView(context: UIViewRepresentableContext<Self>) -> UIActivityIndicatorView {
    UIActivityIndicatorView()
  }

  func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Self>) {
    isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    configuration(uiView)
  }
}
