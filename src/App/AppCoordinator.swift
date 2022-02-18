import ComposableArchitecture
import CommonUI
import Util
import UIKit

@MainActor
final class AppCoordinator {
  var window: UIWindow?

  nonisolated init(routing: Routing) {
    self.routing = routing
  }

  func loadAndStart() async {
    window?.rootViewController = routing.viewController
    await routing.selectLoading(animated: false)
    await Task.wait(.seconds(2))
    await routing.selectTab(animated: true)
  }

  private let routing: Routing
}
