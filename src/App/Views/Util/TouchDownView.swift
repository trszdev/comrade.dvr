import SwiftUI
import UIKit

struct TouchDownView: UIViewRepresentable {
  init(callback: @escaping (_ isEnded: Bool) -> Void) {
    self.callback = { state in
      switch state {
      case .began:
        callback(false)
      case .cancelled, .failed, .ended:
        callback(true)
      default:
        break
      }
    }
  }

  init(callback: @escaping TouchDownCallback) {
    self.callback = callback
  }

  typealias TouchDownCallback = ((_ state: UIGestureRecognizer.State) -> Void)

  var callback: TouchDownCallback

  func makeUIView(context: UIViewRepresentableContext<TouchDownView>) -> UIViewType {
    let view = UIView(frame: .zero)
    let gesture = UILongPressGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.gestureRecognized)
    )
    gesture.delegate = context.coordinator
    gesture.minimumPressDuration = 0
    view.addGestureRecognizer(gesture)
    return view
  }

  class Coordinator: NSObject, UIGestureRecognizerDelegate {
    var callback: TouchDownCallback?

    @objc fileprivate func gestureRecognized(gesture: UILongPressGestureRecognizer) {
      callback?(gesture.state)
    }

    func gestureRecognizer(
      _ gestureRecognizer: UIGestureRecognizer,
      shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
      true
    }
  }

  func makeCoordinator() -> Coordinator {
    let coordinator = Coordinator()
    coordinator.callback = callback
    return coordinator
  }

  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<TouchDownView>) {
  }
}
