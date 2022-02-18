import UIKit

@MainActor
public protocol UIViewControllerProviding {
  var viewController: UIViewController { get }
}

public extension UIViewControllerProviding {
  var viewController: UIViewController { .init() }
}
