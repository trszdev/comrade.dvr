import UIKit

extension UIView {
  static func defaultAnimation(block: @escaping () -> Void) {
    UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: block).startAnimation()
  }
}
