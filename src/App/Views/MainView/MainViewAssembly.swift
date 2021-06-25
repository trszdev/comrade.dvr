import AutocontainerKit
import UIKit

struct MainViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.transient.autoregister(
      MainViewModel.self,
      construct: MainViewModelImpl.init(startViewModelBuilder:settingsViewBuilder:)
    )
    container.transient.autoregister(construct: MainViewBuilder.init(viewModel:customNavigationViewBuilder:))
  }
}
