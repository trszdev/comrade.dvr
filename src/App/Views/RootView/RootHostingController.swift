import SwiftUI
import Combine

struct RootHostingControllerBuilder {
  let mainViewBuilder: MainViewBuilder
  let rootViewModel: RootViewModelImpl

  func makeViewController() -> UIViewController {
    let rootView = RootView(viewModel: rootViewModel, content: mainViewBuilder.makeView)
    let hostingVc = RootHostingController(viewModel: rootViewModel, rootView: rootView.eraseToAnyView())
    return hostingVc
  }
}

final class RootHostingController<ViewModel: RootViewModel>: UIHostingController<AnyView> {
  init(viewModel: ViewModel, rootView: AnyView) {
    self.viewModel = viewModel
    super.init(rootView: rootView)
    self.modalPresentationStyle = .fullScreen
    self.view.backgroundColor = .clear
  }

  required init?(coder aDecoder: NSCoder) {
    notImplemented()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
      return
    }
    viewModel.didChange(userInterfaceStyle: traitCollection.userInterfaceStyle)
  }

  private let viewModel: ViewModel
}

struct RootView<ViewModel: RootViewModel>: View {
  @ObservedObject var viewModel: ViewModel
  @ViewBuilder let content: () -> AnyView
  @Environment(\.locale) var locale: Locale

  var body: some View {
    content()
      .environment(\.locale, viewModel.appLocale.currentLocale ?? locale)
      .environment(\.appLocale, viewModel.appLocale)
      .environment(\.theme, viewModel.theme)
  }
}
