import AutocontainerKit

struct RootViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.singleton.autoregister(construct: RootViewModelImpl.init(themeSetting:languageSetting:))
    container.transient.autoregister(construct: RootHostingControllerBuilder.init(mainViewBuilder:rootViewModel:))
  }
}
