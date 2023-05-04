import UIKit
import Firebase
import Swinject
import App

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    Analytics.logEvent("did_finish_launching", parameters: nil)
    AppAssembly.shared.assemble(container: container)
    return true
  }

  var container = Container()
}
