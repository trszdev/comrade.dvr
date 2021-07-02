import AutocontainerKit

struct RootViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.singleton.autoregister(construct: RootViewModelBuilder.init)
    container.singleton.autoregister(construct: RootViewModelImpl.init(themeSetting:appLocaleModel:application:))
    container.transient.autoregister(
      construct: RootHostingControllerBuilder.init(mainViewBuilder:rootViewModelBuilder:)
    )
  }
}
