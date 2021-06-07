import SwiftUI
import Combine

protocol MainViewModel: ObservableObject {
  var theme: Theme { get }
  var themePublished: Published<Theme> { get }
  var themePublisher: Published<Theme>.Publisher { get }

  var appLocale: AppLocale { get }
  var appLocalePublished: Published<AppLocale> { get }
  var appLocalePublisher: Published<AppLocale>.Publisher { get }

  var startView: AnyView { get }
  var historyView: AnyView { get }
  var settingsView: AnyView { get }

  func systemColorSchemeChanged(to colorScheme: ColorScheme)
}

#if DEBUG

final class MainViewModelImpl: MainViewModel {
  @Published private(set) var theme: Theme
  var themePublished: Published<Theme> { _theme }
  var themePublisher: Published<Theme>.Publisher { $theme }

  @Published private(set) var appLocale: AppLocale
  var appLocalePublished: Published<AppLocale> { _appLocale }
  var appLocalePublisher: Published<AppLocale>.Publisher { $appLocale }

  init(themeSetting: AnySetting<ThemeSetting>, languageSetting: AnySetting<LanguageSetting>) {
    self.themeSetting = themeSetting.value
    theme = themeSetting.value.theme
    appLocale = languageSetting.value.appLocale
    themeSetting.publisher
      .sink { [weak self] newThemeSetting in
        guard let self = self else { return }
        self.themeSetting = newThemeSetting
        self.theme = themeSetting.value.theme
      }
      .store(in: &cancellables)
    languageSetting.publisher
      .sink { [weak self] newLanguageSetting in
        self?.appLocale = newLanguageSetting.appLocale
      }
      .store(in: &cancellables)
    NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification, object: nil)
      .sink { [weak self] _ in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }

  var startView: AnyView {
    let startViewModel = PreviewStartViewModel(
      presentAddNewDeviceScreenStub: {
        PreviewLocator.default.locator.resolve(UINavigationController.self).presentView {
          Color.red.ignoresSafeArea()
        }
      },
      presentConfigureDeviceScreenStub: { device in
        PreviewLocator.default.locator.resolve(UINavigationController.self).presentView {
          ZStack {
            Color.purple.ignoresSafeArea()
            Text(device.name)
          }
        }
      })
    return StartView(viewModel: startViewModel).eraseToAnyView()
  }

  var historyView: AnyView {
    HistoryView().eraseToAnyView()
  }

  var settingsView: AnyView {
    SettingsView(viewModel: PreviewSettingsViewModel()).eraseToAnyView()
  }

  func systemColorSchemeChanged(to colorScheme: ColorScheme) {
    guard themeSetting == .system else {
      return
    }
    theme = colorScheme == .dark ? DarkTheme() : WhiteTheme()
  }

  private var themeSetting: ThemeSetting
  private var cancellables = Set<AnyCancellable>()
}

private extension ThemeSetting {
  var theme: Theme {
    switch self {
    case .dark:
      return DarkTheme()
    case .light:
      return WhiteTheme()
    case .system:
      return UITraitCollection.current.userInterfaceStyle == .dark ? DarkTheme() : WhiteTheme()
    }
  }
}

private extension LanguageSetting {
  var appLocale: AppLocale {
    switch self {
    case .english:
      return LocaleImpl(languageCode: .en)
    case .system:
      return LocaleImpl()
    case .russian:
      return LocaleImpl(languageCode: .ru)
    }
  }
}

#endif
