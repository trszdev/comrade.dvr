import UIKit
import SwiftUI
import AutocontainerKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene,
      let appDelegate = UIApplication.shared.delegate as? AppDelegate
    else {
      return
    }
    let window = UIWindow(windowScene: windowScene)
    let rootViewController = appDelegate.locator.resolve(RootHostingControllerBuilder.self).makeViewController()
    window.rootViewController = rootViewController
    self.window = window
    window.makeKeyAndVisible()
  }
}
