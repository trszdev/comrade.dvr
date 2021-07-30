import UIKit
import AutocontainerKit
import Accessibility

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    return true
  }

  lazy var locator: AKLocator = AppAssembly(isPreview: isPreview).locator

  private var isPreview: Bool {
    CommandLine.arguments.contains(LaunchArgs.isRunningPreview.rawValue)
  }
}
