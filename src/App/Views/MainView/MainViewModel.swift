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

final class MainViewModelImpl: MainViewModel {
  @Published private(set) var theme: Theme
  var themePublished: Published<Theme> { _theme }
  var themePublisher: Published<Theme>.Publisher { $theme }

  @Published private(set) var appLocale: AppLocale
  var appLocalePublished: Published<AppLocale> { _appLocale }
  var appLocalePublisher: Published<AppLocale>.Publisher { $appLocale }

  init(
    themeSetting: AnySetting<ThemeSetting>,
    languageSetting: AnySetting<LanguageSetting>,
    navigationController: UINavigationController,
    settingsViewBuilder: SettingsView.Builder
  ) {
    self.navigationController = navigationController
    self.themeSetting = themeSetting.value
    self.settingsView = settingsViewBuilder.makeView()
    self.theme = themeSetting.value.isDark ? DarkTheme() : WhiteTheme()
    self.appLocale = languageSetting.value.appLocale
    themeSetting.publisher
      .sink { [weak self] newThemeSetting in
        guard let self = self else { return }
        self.themeSetting = newThemeSetting
        self.changeTheme(isDark: newThemeSetting.isDark)
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
    let startViewModel = StartViewModelImpl(
      presentAddNewDeviceScreenStub: { [navigationController] in
        navigationController?.presentView {
          Color.red.ignoresSafeArea()
        }
      },
      presentConfigureDeviceScreenStub: { [navigationController] device in
        navigationController?.presentView {
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

  let settingsView: AnyView

  func systemColorSchemeChanged(to colorScheme: ColorScheme) {
    guard themeSetting == .system else {
      return
    }
    changeTheme(isDark: colorScheme == .dark)
  }

  private func changeTheme(isDark: Bool) {
    for window in UIApplication.shared.windows {
      window.overrideUserInterfaceStyle = isDark ? .dark : .light
    }
    theme = isDark ? DarkTheme() : WhiteTheme()
  }

  private var themeSetting: ThemeSetting
  private var cancellables = Set<AnyCancellable>()
  private weak var navigationController: UINavigationController?
}

private extension ThemeSetting {
  var isDark: Bool {
    switch self {
    case .dark:
      return true
    case .light:
      return false
    case .system:
      return UITraitCollection.current.userInterfaceStyle == .dark
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
