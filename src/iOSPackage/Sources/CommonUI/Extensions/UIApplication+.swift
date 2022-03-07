import UIKit

public extension UIApplication {
  var window: UIWindow? {
    windows.first { $0.isKeyWindow }
  }

  var topViewController: UIViewController? {
    window?.rootViewController?.topmostPresented
  }
}
