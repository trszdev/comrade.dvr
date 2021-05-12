import SwiftUI

struct SettingsView: View {
  @Environment(\.theme) var theme: Theme
  @Environment(\.safeAreaInsets) var safeAreaInsets: EdgeInsets

  var body: some View {
    ZStack {
      theme.startHeaderBackgroundColor.ignoresSafeArea()
      CustomScrollView(isVertical: true) {
        settingsView.edgesIgnoringSafeArea(.horizontal).padding(.top, safeAreaInsets.top < 10 ? 40 : 0)
      }
      .edgesIgnoringSafeArea(.horizontal)
    }
  }

  private var settingsView: some View {
    LazyVStack(alignment: .leading, spacing: 0) {
      sectionView {
        SettingsCellView(text: "Assets limit", rightText: "10Gb", sfSymbol: .assetLimit)
        SettingsCellView(text: "Asset length", rightText: "5min", sfSymbol: .assetLength)
        SettingsCellView(
          text: "Used space",
          rightText: "1,2Gb",
          sfSymbol: .usedSpace,
          isLast: true,
          isDisabled: true
        )
        SettingsCellButtonView(text: "Clear assets")
      }
      sectionView {
        SettingsCellView(text: "Language", rightText: "System", sfSymbol: .language)
        SettingsCellView(text: "Theme", rightText: "System", sfSymbol: .theme, isLast: true)
      }
      sectionView {
        SettingsCellView(text: "Contact us", rightText: "help@comradedvr.app", sfSymbol: .contactUs)
        SettingsCellView(text: "Rate app", sfSymbol: .star, isLast: true)
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
    SettingsView()// .environment(\.theme, DarkTheme())
  }
}

#endif
