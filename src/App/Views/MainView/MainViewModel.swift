import SwiftUI
import Combine

protocol MainViewModel {
  var startView: AnyView { get }
  var historyView: AnyView { get }
  var settingsView: AnyView { get }
}

final class MainViewModelImpl: MainViewModel {
  init(
    startViewModelBuilder: StartViewModelBuilder,
    settingsViewBuilder: SettingsView.Builder
  ) {
    self.startViewModelBuilder = startViewModelBuilder
    self.settingsViewBuilder = settingsViewBuilder
  }

  var startView: AnyView {
    let viewModel = startViewModelBuilder.makeViewModel()
    return StartView(viewModel: viewModel).eraseToAnyView()
  }

  var historyView: AnyView {
    HistoryView().eraseToAnyView()
  }

  var settingsView: AnyView {
    settingsViewBuilder.makeView()
  }

  private let startViewModelBuilder: StartViewModelBuilder
  private let settingsViewBuilder: SettingsView.Builder
}
