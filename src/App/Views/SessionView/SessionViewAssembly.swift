import AutocontainerKit

struct SessionViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.transient.autoregister(construct: SessionViewBuilder.init)
    container.transient.autoregister(construct: SessionViewController.Builder.init)
    container.transient.autoregister(construct: SessionViewModelBuilder.init)
  }
}
