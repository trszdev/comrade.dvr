import UIKit
import Firebase
import Swinject

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    Analytics.logEvent("did_finish_launching", parameters: nil)
    AppAssembly().assemble(container: container)
    return true
  }

  var container = Container()
}
