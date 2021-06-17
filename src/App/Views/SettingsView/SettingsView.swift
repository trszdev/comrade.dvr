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
    TableView(sections: viewModel.sections)
  }
}

#if DEBUG

struct SettingsViewPreview: PreviewProvider {
  static var previews: some View {
    locator.resolve(SettingsView.Builder.self).makeView()
  }
}

#endif
