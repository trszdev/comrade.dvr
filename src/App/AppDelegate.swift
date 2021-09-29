import UIKit
import AutocontainerKit
import Accessibility
import Firebase

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    Analytics.logEvent("did_finish_launching", parameters: nil)
    return true
  }

  lazy var locator: AKLocator = AppAssembly(isPreview: isPreview).locator

  private var isPreview: Bool {
    CommandLine.arguments.contains(LaunchArgs.isRunningPreview.rawValue)
  }
}
