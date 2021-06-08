import SwiftUI

struct MainViewBuilder {
  let viewModel: MainViewModelImpl
  let customNavigationViewBuilder: CustomNavigationViewBuilder

  func makeView() -> AnyView {
    MainView(viewModel: viewModel, customNavigationViewBuilder: customNavigationViewBuilder).eraseToAnyView()
  }
}

struct MainView<ViewModel: MainViewModel>: View {
  @ObservedObject var viewModel: ViewModel
  let customNavigationViewBuilder: CustomNavigationViewBuilder
  @Environment(\.colorScheme) var colorScheme: ColorScheme

  var body: some View {
    GeometryReader { geometry in
      customNavigationViewBuilder.makeView {
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
    locator.resolve(MainViewBuilder.self).makeView()
  }
}

#endif
