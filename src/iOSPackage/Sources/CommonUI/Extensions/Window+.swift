import UIKit

public extension UIWindow {
  @discardableResult
  func set(rootViewController: UIViewController, animated: Bool) async -> Bool {
    self.rootViewController = rootViewController
    guard animated else { return true }
    return await withCheckedContinuation { continuation in
      UIView.transition(
        with: self,
        duration: 0.4,
        options: .transitionCrossDissolve
      ) {
      } completion: { done in
        continuation.resume(returning: done)
      }
    }
  }
}
