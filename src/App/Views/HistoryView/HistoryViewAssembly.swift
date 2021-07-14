import AutocontainerKit

struct HistoryViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.transient.autoregister(construct: HistoryTableViewBuilder.init)
    container.transient.autoregister(construct: HistoryViewBuilder.init)
    container.singleton.autoregister(construct: HistoryViewModelImpl.init)
    container.transient.autoregister(HistorySelectionViewModel.self) { (locator: AKLocator) in
      locator.resolve(HistoryViewModelImpl.self)
    }
    container.singleton.autoregister(construct: HistoryTableViewModelImpl.init)
  }
}
