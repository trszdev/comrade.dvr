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
    settingsViewBuilder: SettingsView.Builder,
    configureCameraView: ConfigureMicrophoneViewBuilder
  ) {
    self.navigationController = navigationController
    self.settingsView = settingsViewBuilder.makeView()
    self.configureCameraView = configureCameraView
  }

  var startView: AnyView {
    let startViewModel = StartViewModelImpl(
      presentAddNewDeviceScreenStub: { [navigationController] in
        navigationController?.presentView {
          Color.red.ignoresSafeArea()
        }
      },
      presentConfigureDeviceScreenStub: { [navigationController, configureCameraView] _ in
        navigationController?.presentView {
          configureCameraView.makeView()
        }
      })
    return StartView(viewModel: startViewModel).eraseToAnyView()
  }

  var historyView: AnyView {
    HistoryView().eraseToAnyView()
  }

  let settingsView: AnyView

  private let configureCameraView: ConfigureMicrophoneViewBuilder
  private weak var navigationController: UINavigationController?
}
