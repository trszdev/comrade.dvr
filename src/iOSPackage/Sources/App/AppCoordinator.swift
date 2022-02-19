import ComposableArchitecture
import CommonUI
import Util
import UIKit
import Combine
import Assets

@MainActor
public final class AppCoordinator {
  public var window: UIWindow?

  public nonisolated init(
    routing: Routing,
    appearancePublisher: CurrentValuePublisher<Appearance?>
  ) {
    self.routing = routing
    self.appearancePublisher = appearancePublisher
  }

  public func loadAndStart() async {
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
