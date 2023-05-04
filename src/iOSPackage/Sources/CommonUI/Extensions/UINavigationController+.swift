import UIKit

public extension UINavigationController {
  func push(
    viewController: UIViewController,
    animated: Bool,
    completion: (() -> Void)?
  ) {
    trackAnimation(animated: animated, completion: completion) {
      pushViewController(viewController, animated: animated)
    }
  }

  func popLast(animated: Bool, completion: (() -> Void)?) {
    trackAnimation(animated: animated, completion: completion) {
      popViewController(animated: animated)
    }
  }

  func set(
    viewControllers: [UIViewController],
    animated: Bool,
    completion: (() -> Void)?
  ) {
    trackAnimation(animated: animated, completion: completion) {
      setViewControllers(viewControllers, animated: animated)
    }
  }

  func push(viewController: UIViewController, animated: Bool) async {
    await withCheckedContinuation { continuation in
      push(viewController: viewController, animated: animated) {
        continuation.resume()
      }
    }
  }

  func popLast(animated: Bool) async {
    await withCheckedContinuation { continuation in
      popLast(animated: animated) {
        continuation.resume()
      }
    }
  }

  func set(viewControllers: [UIViewController], animated: Bool) async {
    await withCheckedContinuation { continuation in
      set(viewControllers: viewControllers, animated: animated) {
        continuation.resume()
      }
    }
  }
}

private func trackAnimation(animated: Bool, completion: (() -> Void)?, block: () -> Void) {
  if animated {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    block()
    CATransaction.commit()
  } else {
    block()
    completion?()
  }
}
