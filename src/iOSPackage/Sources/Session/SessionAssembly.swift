import Swinject
import SwinjectExtensions
import SwinjectAutoregistration
import Assets
import Util

public enum SessionAssembly: SharedAssembly {
  case shared

  public func assemble(container: Container) {
    container.autoregister(SessionView.self, initializer: SessionView.init)
  }
}
