import ComposableArchitecture
import CommonUI
import Util
import UIKit
import Combine
import Assets

@MainActor
final class AppCoordinator {
  var window: UIWindow?

  nonisolated init(
    routing: Routing,
    appearancePublisher: CurrentValuePublisher<Appearance?>
  ) {
    self.routing = routing
    self.appearancePublisher = appearancePublisher
  }

  func loadAndStart() async {
    window?.rootViewController = routing.viewController
    appearancePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak window] appearance in
        window?.overrideUserInterfaceStyle = appearance.interfaceStyle
      }
      .store(in: &cancellables)
    await routing.selectLoading(animated: false)
    await Task.wait(.seconds(1))
    await routing.selectTab(animated: true)
  }

  private let routing: Routing
  private let appearancePublisher: CurrentValuePublisher<Appearance?>
  private var cancellables = Set<AnyCancellable>()
}
