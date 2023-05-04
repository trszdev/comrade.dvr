import Swinject
import SwinjectExtensions
import SwinjectAutoregistration

public enum StartAssembly: SharedAssembly {
  case shared

  public func assemble(container: Container) {
    container.autoregister(StartView.self, initializer: StartView.init(store:))
  }
}
