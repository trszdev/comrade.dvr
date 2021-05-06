import SwiftUI

protocol MainViewModel {
  var startView: AnyView { get }
  var historyView: AnyView { get }
  var settingsView: AnyView { get }
}

struct MainView: View {
  let viewModel: MainViewModel

  var body: some View {
    CustomTabView(
      views: [
        viewModel.startView,
        viewModel.historyView,
        viewModel.settingsView,
      ],
      labels: [
        (.play, "Start"),
        (.history, "History"),
        (.settings, "Settings"),
      ]
    ).ignoresSafeArea()
  }
}

struct PreviewMainViewModel: MainViewModel {
  var startView: AnyView {
    AnyView(StartView())
  }

  var historyView: AnyView {
    AnyView(Color.blue.ignoresSafeArea())
  }

  var settingsView: AnyView {
    AnyView(Color.green.ignoresSafeArea())
  }
}

#if DEBUG

struct MainViewPreview: PreviewProvider {
  static var previews: some View {
    MainView(viewModel: PreviewMainViewModel()).environment(\.theme, DarkTheme())
  }
}

#endif
