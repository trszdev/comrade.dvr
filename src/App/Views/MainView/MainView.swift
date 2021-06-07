import SwiftUI

struct MainView<ViewModel: MainViewModel>: View {
  @ObservedObject var viewModel: ViewModel
  @Environment(\.colorScheme) var colorScheme: ColorScheme

  var body: some View {
    GeometryReader { geometry in
      CustomNavigationView {
        CustomTabView(
          views: [
            viewModel.startView,
            viewModel.historyView,
            viewModel.settingsView,
          ],
          labels: [
            (.play, viewModel.appLocale.recordString),
            (.history, viewModel.appLocale.historyString),
            (.settings, viewModel.appLocale.settingsString),
          ]
        )
        .ignoresSafeArea()
      }
      .ignoresSafeArea()
      .environment(\.geometry, Geometry(size: geometry.size, safeAreaInsets: geometry.safeAreaInsets))
      .environment(\.appLocale, viewModel.appLocale)
      .environment(\.theme, viewModel.theme)
      .onChange(of: colorScheme) { newColorScheme in
        viewModel.systemColorSchemeChanged(to: newColorScheme)
      }
    }
  }
}

#if DEBUG

struct MainViewPreview: PreviewProvider {
  static var previews: some View {
    PreviewLocator.default.makeMainView()
  }
}

#endif
