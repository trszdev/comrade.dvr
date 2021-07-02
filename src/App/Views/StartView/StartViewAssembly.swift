import AutocontainerKit

struct StartViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.transient.autoregister(construct: StartViewModelBuilder.init)
  }
}
