import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    #if DEBUG
    print(">>>>")
    #endif
    #if TEST_CAMERAKIT_APP
    print(123)
    #else
    print(ProcessInfo.processInfo.environment)
    #endif
    return true
  }
}
