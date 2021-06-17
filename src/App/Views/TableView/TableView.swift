import SwiftUI

struct TableView: View {
  let sections: [[AnyView]]
  @Environment(\.theme) var theme: Theme
  @Environment(\.geometry) var geometry: Geometry

  var body: some View {
    ZStack {
      theme.startHeaderBackgroundColor.ignoresSafeArea()
      ScrollView {
        settingsView
          .edgesIgnoringSafeArea(.horizontal)
          .padding(.top, geometry.safeAreaInsets.top < 10 ? 40 : 0)
      }
      .edgesIgnoringSafeArea(.horizontal)
    }
  }

  private var settingsView: some View {
    LazyVStack(alignment: .leading, spacing: 0) {
      ForEach(array: sections) { section in
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

struct TableViewPreview: PreviewProvider {
  static var previews: some View {
    TableView(sections: [
      [
        TableSwitchCellView(isOn: .constant(true), sfSymbol: .play, text: "Switch").eraseToAnyView(),
        TableSwitchCellView(
          isOn: .constant(true),
          sfSymbol: .play,
          text: "Switch",
          isDisabled: true
        )
        .eraseToAnyView(),
      ],
    ])
  }
}

#endif
