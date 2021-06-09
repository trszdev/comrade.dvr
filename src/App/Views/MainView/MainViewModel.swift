import SwiftUI
import Combine

protocol MainViewModel {
  var startView: AnyView { get }
  var historyView: AnyView { get }
  var settingsView: AnyView { get }
}

final class MainViewModelImpl: MainViewModel {
  init(
    navigationController: UINavigationController,
    settingsViewBuilder: SettingsView.Builder
  ) {
    self.navigationController = navigationController
    self.settingsView = settingsViewBuilder.makeView()
  }

  var startView: AnyView {
    let startViewModel = StartViewModelImpl(
      presentAddNewDeviceScreenStub: { [navigationController] in
        navigationController?.presentView {
          Color.red.ignoresSafeArea()
        }
      },
      presentConfigureDeviceScreenStub: { [navigationController] device in
        navigationController?.presentView {
          ZStack {
            Color.purple.ignoresSafeArea()
            Text(device.name)
          }
        }
      })
    return StartView(viewModel: startViewModel).eraseToAnyView()
  }

  var historyView: AnyView {
    HistoryView().eraseToAnyView()
  }

  let settingsView: AnyView

  private weak var navigationController: UINavigationController?
}
