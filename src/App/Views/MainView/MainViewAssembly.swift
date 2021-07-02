import AutocontainerKit
import UIKit

struct MainViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.transient.autoregister(MainViewModel.self, construct: MainViewModelImpl.init)
    container.transient.autoregister(construct: MainViewBuilder.init)
  }
}
