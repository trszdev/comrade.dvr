import SwiftUI

public struct UIViewRepresentableView: UIViewRepresentable {
  public init(view: UIView) {
    self.view = view
  }

  let view: UIView

  public func makeUIView(context: Context) -> UIView {
    view
  }

  public func updateUIView(_ uiView: UIView, context: Context) {
  }
}
