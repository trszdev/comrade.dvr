import SwiftUI

struct CustomScrollView<Content: View>: UIViewRepresentable {
  var isVertical = true
  var bounces = true
  @ViewBuilder let content: () -> Content

  func makeUIView(context: Context) -> UIScrollView {
    let result = SimultaneousScrollView()
    if isVertical {
      result.alwaysBounceVertical = bounces
    } else {
      result.alwaysBounceHorizontal = bounces
    }
    return result
  }

  func updateUIView(_ uiView: UIScrollView, context: Context) {
    let hosting = UIHostingController(rootView: content())
    hosting.view.backgroundColor = .clear
    for view in uiView.subviews {
      view.removeFromSuperview()
    }
    uiView.addSubview(hosting.view)
    hosting.view.translatesAutoresizingMaskIntoConstraints = false
    uiView.addConstraints([
      hosting.view.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
      hosting.view.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
      hosting.view.topAnchor.constraint(equalTo: uiView.topAnchor),
      hosting.view.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
      isVertical ?
        hosting.view.widthAnchor.constraint(equalTo: uiView.widthAnchor) :
        hosting.view.heightAnchor.constraint(equalTo: uiView.heightAnchor),
    ])
  }
}

private class SimultaneousScrollView: UIScrollView, UIGestureRecognizerDelegate {
  func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
    true
  }
}
