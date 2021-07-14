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
    settingsViewBuilder: SettingsView.Builder,
    historyViewBuilder: HistoryViewBuilder
  ) {
    self.startViewModelBuilder = startViewModelBuilder
    self.settingsViewBuilder = settingsViewBuilder
    self.historyViewBuilder = historyViewBuilder
  }

  var startView: AnyView {
    let viewModel = startViewModelBuilder.makeViewModel()
    return StartView(viewModel: viewModel).eraseToAnyView()
  }

  var historyView: AnyView {
    historyViewBuilder.makeView()
  }

  var settingsView: AnyView {
    settingsViewBuilder.makeView()
  }

  private let startViewModelBuilder: StartViewModelBuilder
  private let settingsViewBuilder: SettingsView.Builder
  private let historyViewBuilder: HistoryViewBuilder
}
