import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    let container = AppAssembly(isPreview: false).hashContainer
    let mainView = container.resolve(MainViewBuilder.self).makeView()
    window.rootViewController = UIHostingController(rootView: mainView)
    self.window = window
    window.makeKeyAndVisible()
  }
}
