import UIKit
import SwiftUI
import App
import AVFoundation

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene,
      let appDelegate = UIApplication.shared.delegate as? AppDelegate,
      let appCoordinator = appDelegate.container.resolve(AppCoordinator.self)
    else {
      return
    }
    test()
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = UIViewController()
    window.makeKeyAndVisible()
    appCoordinator.window = window
    Task {
      await appCoordinator.loadAndStart()
    }
  }

  func test() {
    let multicamSets = AVCaptureDevice.DiscoverySession(
      deviceTypes: [
        .builtInDualCamera,
        .builtInDualWideCamera,
        .builtInTelephotoCamera,
        .builtInTripleCamera,
        .builtInTrueDepthCamera,
        .builtInUltraWideCamera,
        .builtInWideAngleCamera,
      ],
      mediaType: nil,
      position: .unspecified
    ).supportedMultiCamDeviceSets
    print(multicamSets)
  }
}
