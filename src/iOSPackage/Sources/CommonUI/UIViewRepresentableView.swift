import SwiftUI

public struct UIViewRepresentableView: UIViewRepresentable, Equatable {
  public init(view: UIView) {
    self.view = view
  }

  public let view: UIView

  public func makeUIView(context: Context) -> UIView {
    ContainerView()
  }

  public func updateUIView(_ uiView: UIView, context: Context) {
    let containerView = uiView as? ContainerView
    containerView?.view = view
  }
}

private final class ContainerView: UIView {
  var view: UIView? {
    didSet {
      guard let view else { return }
      view.removeFromSuperview()
      addSubview(view)
      setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    view?.frame = bounds
  }
}
