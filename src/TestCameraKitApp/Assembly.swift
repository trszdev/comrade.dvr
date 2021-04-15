import AutocontainerKit

struct Assembly: AKAssembly {
  func assemble(container: AKContainer) {
    let logViewModel = LogViewModelImpl()
    container.singleton.autoregister(value: logViewModel)
    container.singleton.autoregister(Logger.self, value: logViewModel)
    container.transient.autoregister { (locator: AKLocator) in
      ConsoleView(viewModel: locator.resolve(LogViewModelImpl.self))
    }
    container.transient.autoregister(
      CameraKitViewBuilder.self,
      construct: CameraKitViewBuilderImpl.init(logger:shareViewPresenter:consoleView:)
    )
    container.transient.autoregister(ShareViewPresenter.self, construct: ShareViewPresenterImpl.init(logger:))
  }
}
