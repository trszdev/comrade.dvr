import AutocontainerKit

struct HistoryViewAssembly: AKAssembly {
  let isPreview: Bool

  func assemble(container: AKContainer) {
    if isPreview {
      container.singleton.autoregister(construct: PreviewHistoryTableViewModel.init)
      container.transient.autoregister(HistoryTableViewBuilder.self, construct: PreviewHistoryTableViewBuilder.init)
    } else {
      container.singleton.autoregister(construct: HistoryTableViewModelImpl.init)
      container.transient.autoregister(HistoryTableViewBuilder.self, construct: HistoryTableViewBuilderImpl.init)
    }
    container.transient.autoregister(HistorySelectionComputer.self, construct: HistorySelectionComputerImpl.init)
    container.transient.autoregister(construct: HistorySelectionComputerImpl.init)
    container.transient.autoregister(construct: HistoryViewBuilder.init)
    container.singleton.autoregister(construct: HistoryViewModelImpl.init)
    container.transient.autoregister(HistorySelectionViewModel.self) { (locator: AKLocator) in
      locator.resolve(HistoryViewModelImpl.self)
    }
  }
}
