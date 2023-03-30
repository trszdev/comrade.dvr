import UIKit
import Foundation

public extension UIWindow {
  @discardableResult
  func fade(rootViewController: UIViewController, animated: Bool) async -> Bool {
    await set(rootViewController, animated: animated, duration: 0.4, options: .transitionCrossDissolve)
  }

  @discardableResult
  func curlUp(rootViewController: UIViewController, animated: Bool) async -> Bool {
    await set(rootViewController, animated: animated, duration: 0.4, options: .transitionCurlUp)
  }

  @discardableResult
  func curlDown(rootViewController: UIViewController, animated: Bool) async -> Bool {
    await set(rootViewController, animated: animated, duration: 0.4, options: .transitionCurlDown)
  }

  @discardableResult
  private func set(
    _ rootViewController: UIViewController,
    animated: Bool,
    duration: TimeInterval,
    options: UIView.AnimationOptions = []
  ) async -> Bool {
    self.rootViewController = rootViewController
    guard animated else { return true }
    return await withCheckedContinuation { continuation in
      UIView.transition(
        with: self,
        duration: duration,
        options: options
      ) {
      } completion: { done in
        continuation.resume(returning: done)
      }
    }
  }
}
