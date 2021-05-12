import SwiftUI

struct MainView: View {
  let viewModel: MainViewModel

  var body: some View {
    CustomNavigationView(navigationViewController: viewModel.navigationViewController) {
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
    }.ignoresSafeArea()
  }
}

#if DEBUG

struct MainViewPreview: PreviewProvider {
  static var previews: some View {
    MainView(viewModel: PreviewMainViewModel()).environment(\.theme, DarkTheme())
  }
}

#endif
