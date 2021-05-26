import SwiftUI

struct MainView: View {
  @Environment(\.locale) var locale: Locale
  let viewModel: MainViewModel

  var body: some View {
    GeometryReader { geometry in
      CustomNavigationView(navigationViewController: viewModel.navigationViewController) {
        CustomTabView(
          views: [
            viewModel.startView,
            viewModel.historyView,
            viewModel.settingsView,
          ],
          labels: [
            (.play, locale.recordString),
            (.history, locale.historyString),
            (.settings, locale.settingsString),
          ]
        )
        .ignoresSafeArea()
      }
      .ignoresSafeArea()
      .environment(\.geometry, Geometry(size: geometry.size, safeAreaInsets: geometry.safeAreaInsets))
    }
  }
}

#if DEBUG

struct MainViewPreview: PreviewProvider {
  static var previews: some View {
    MainView(viewModel: PreviewMainViewModel()).environment(\.theme, DarkTheme())
  }
}

#endif
