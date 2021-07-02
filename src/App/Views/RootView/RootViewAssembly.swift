import AutocontainerKit

struct RootViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.singleton.autoregister(construct: RootViewModelBuilder.init)
    container.singleton.autoregister(construct: RootViewModelImpl.init)
    container.transient.autoregister(construct: RootHostingControllerBuilder.init)
  }
}
