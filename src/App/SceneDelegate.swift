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
    let mainView = MainView(viewModel: PreviewMainViewModel())
      .environment(\.theme, DarkTheme())
      .environment(\.locale, LocaleImpl(languageCode: .ru))
    window.rootViewController = UIHostingController(rootView: mainView)
    self.window = window
    window.makeKeyAndVisible()
  }
}
