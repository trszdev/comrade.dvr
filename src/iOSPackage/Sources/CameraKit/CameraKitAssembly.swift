import Swinject
import SwinjectExtensions
import SwinjectAutoregistration
import Device

public enum CameraKitAssembly: SharedAssembly {
  case shared

  public func assemble(container: Container) {
    container
      .autoregister(SessionConfigurator.self, initializer: SessionConfiguratorStub.init)
      .inObjectScope(.container)
  }
}
