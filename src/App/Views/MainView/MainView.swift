import SwiftUI

struct MainViewBuilder {
  let viewModel: MainViewModel
  let customNavigationViewBuilder: CustomNavigationViewBuilder

  func makeView() -> AnyView {
    MainView(viewModel: viewModel, customNavigationViewBuilder: customNavigationViewBuilder).eraseToAnyView()
  }
}

struct MainView: View {
  let viewModel: MainViewModel
  let customNavigationViewBuilder: CustomNavigationViewBuilder

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
            CustomTabViewLabel(sfSymbol: .play, accessibility: .tabBarPlayButton) { $0.playString },
            CustomTabViewLabel(sfSymbol: .history, accessibility: .tabBarHistoryButton) { $0.historyString },
            CustomTabViewLabel(sfSymbol: .settings, accessibility: .tabBarSettingsButton) { $0.settingsString },
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
    locator.resolve(MainViewBuilder.self).makeView()
  }
}

#endif
