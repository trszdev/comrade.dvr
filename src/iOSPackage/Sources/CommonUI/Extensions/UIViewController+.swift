import UIKit

public extension UIViewController {
  func present(viewController: UIViewController, animated: Bool) async {
    await withCheckedContinuation { continuation in
      present(viewController, animated: animated) {
        continuation.resume()
      }
    }
  }
}
