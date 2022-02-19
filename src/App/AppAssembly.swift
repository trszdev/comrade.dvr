import Swinject
import Util
import Assets
import Combine
import MainScreen

struct AppAssembly: Assembly {
  func assemble(container: Container) {
    RoutingAssembly().assemble(container: container)
    container
      .autoregister(AppCoordinator.self, initializer: AppCoordinator.init)
      .inObjectScope(.container)
    container
      .register(CurrentValuePublisher<Language?>.self) { _ in
        CurrentValueSubject<Language?, Never>(.en).currentValuePublisher
      }
      .inObjectScope(.container)
    container
      .register(CurrentValuePublisher<Appearance?>.self) { _ in
        CurrentValueSubject<Appearance?, Never>(.dark).currentValuePublisher
      }
      .inObjectScope(.container)
    container.autoregister(TabBarViewController.self, initializer: TabBarViewController.init)
  }
}
