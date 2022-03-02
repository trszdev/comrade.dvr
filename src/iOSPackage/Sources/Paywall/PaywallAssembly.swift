import Swinject
import SwinjectExtensions
import SwinjectAutoregistration

public enum PaywallAssembly: SharedAssembly {
  case shared

  public func assemble(container: Container) {
    container.autoregister(PaywallView.self, initializer: PaywallView.init)
  }
}
