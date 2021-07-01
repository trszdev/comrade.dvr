import AutocontainerKit
import UIKit

struct UtilAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    let navigationController = CustomNavigationController()
    container.singleton.autoregister(UINavigationController.self, value: navigationController)
    container.singleton.autoregister(NavigationViewPresenter.self, value: navigationController)
    container.transient.autoregister(construct: CustomNavigationViewBuilder.init(navigationViewController:))
    container.transient.autoregister(ModalViewPresenter.self, construct: ModalViewPresenterImpl.init)
    container.transient.autoregister(Haptics.self, construct: HapticsImpl.init)
  }
}
