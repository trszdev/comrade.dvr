import Swinject
import SwinjectExtensions
import SwinjectAutoregistration

public enum DeviceAssembly: SharedAssembly {
  case shared

  public func assemble(container: Container) {
    container
      .autoregister(DeviceConfigurationRepository.self, initializer: DeviceConfigurationRepositoryImpl.init)
      .inObjectScope(.transient)
  }
}
