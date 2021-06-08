import SwiftUI

struct SettingsView: View {
  struct Builder {
    let viewModel: SettingsViewModel

    func makeView() -> AnyView {
      SettingsView(viewModel: viewModel).eraseToAnyView()
    }
  }

  @Environment(\.theme) var theme: Theme
  @Environment(\.geometry) var geometry: Geometry
  let viewModel: SettingsViewModel

  var body: some View {
    ZStack {
      theme.startHeaderBackgroundColor.ignoresSafeArea()
      CustomScrollView {
        settingsView
          .edgesIgnoringSafeArea(.horizontal)
          .padding(.top, geometry.safeAreaInsets.top < 10 ? 40 : 0)
      }
      .edgesIgnoringSafeArea(.horizontal)
    }
  }

  private var settingsView: some View {
    LazyVStack(alignment: .leading, spacing: 0) {
      ForEach(array: viewModel.sections) { section in
        sectionView {
          ForEach(array: section)
        }
      }
    }
  }

  private func sectionView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    Section {
      VStack(spacing: 0, content: content)
        .border(width: 0.5, edges: [.top, .bottom], color: theme.textColor)
        .padding(.bottom, 40)
    }
  }
}

#if DEBUG

struct SettingsViewPreview: PreviewProvider {
  static var previews: some View {
    locator.resolve(SettingsView.Builder.self).makeView()
  }
}

#endif
