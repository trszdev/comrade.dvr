import AutocontainerKit
import SwiftUI

struct PreviewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.registerMany(assemblies: [
      PreviewSettingsAssembly(),
      PreviewSettingsViewAssembly(),
      PreviewMainViewAssembly(),
    ])
    container.transient.autoregister(construct: MainViewModelImpl.init(themeSetting:languageSetting:))
    container.transient.autoregister(construct: { (mainViewModel: MainViewModelImpl) in
      MainView(viewModel: mainViewModel)
    })
  }
}

struct PreviewLocator {
  static let `default` = PreviewLocator()

  let locator: AKLocator = PreviewAssembly().hashContainer

  func makeMainView() -> AnyView {
    locator.resolve(MainView<MainViewModelImpl>.self).eraseToAnyView()
  }
}
