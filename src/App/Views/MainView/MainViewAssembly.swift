import AutocontainerKit
import UIKit

struct MainViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.transient.autoregister(
      construct: MainViewModelImpl.init(themeSetting:languageSetting:navigationController:settingsViewBuilder:)
    )
    container.transient.autoregister(construct: MainViewBuilder.init(viewModel:customNavigationViewBuilder:))
  }
}
