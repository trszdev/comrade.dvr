import UIKit

public extension UIViewController {
  func present(viewController: UIViewController, animated: Bool) async {
    await withCheckedContinuation { continuation in
      present(viewController, animated: animated) {
        continuation.resume()
      }
    }
  }

  var topmostPresented: UIViewController {
    var presented = self
    while let newPresented = presented.presentedViewController {
      presented = newPresented
    }
    return presented
  }
}
