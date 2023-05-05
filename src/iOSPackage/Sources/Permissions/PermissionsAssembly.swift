import Swinject
import SwinjectExtensions
import SwinjectAutoregistration
import Assets
import Util

public enum PermissionsAssembly: SharedAssembly {
  case shared

  public func assemble(container: Container) {
    container
      .register(PermissionControllerCoordinating.self) { resolver in
        PermissionControllerCoordinator(
          languagePublisher: resolver.resolve(CurrentValuePublisher<Language?>.self)!,
          permissions: [.camera, .microphone]
        )
      }
      .inObjectScope(.transient)
    container.registerSingleton(PermissionChecker.self) { _ in PermissionChecker.live }
    container
      .autoregister(PermissionDialogPresenting.self, initializer: PermissionDialogPresenter.init)
      .inObjectScope(.transient)
  }
}
