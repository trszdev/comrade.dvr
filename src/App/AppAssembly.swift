import Swinject

struct AppAssembly: Assembly {
  func assemble(container: Container) {
    RoutingAssembly().assemble(container: container)
    container
      .autoregister(AppCoordinator.self, initializer: AppCoordinator.init)
      .inObjectScope(.container)
  }
}
