import UIKit

extension UIWindow {
  var topViewController: UIViewController? {
    var topVc = rootViewController
    while let newTopController = topVc?.presentedViewController {
      topVc = newTopController
    }
    return topVc
  }
}
