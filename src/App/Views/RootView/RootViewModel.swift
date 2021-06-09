import SwiftUI
import Combine

protocol RootViewModel: ObservableObject {
  var theme: Theme { get }
  var themePublished: Published<Theme> { get }
  var themePublisher: Published<Theme>.Publisher { get }

  var appLocale: AppLocale { get }
  var appLocalePublished: Published<AppLocale> { get }
  var appLocalePublisher: Published<AppLocale>.Publisher { get }

  func didChange(userInterfaceStyle: UIUserInterfaceStyle)
}

final class RootViewModelImpl: RootViewModel {
  init(
    themeSetting: AnySetting<ThemeSetting>,
    languageSetting: AnySetting<LanguageSetting>
  ) {
    self.themeSetting = themeSetting.value
    self.theme = WhiteTheme()
    self.appLocale = languageSetting.value.appLocale
    updateCurrentTheme()
    themeSetting.publisher
      .sink { [weak self] newThemeSetting in
        guard let self = self else { return }
        self.themeSetting = newThemeSetting
        self.updateCurrentTheme()
      }
      .store(in: &cancellables)
    languageSetting.publisher
      .sink { [weak self] newLanguageSetting in
        self?.appLocale = newLanguageSetting.appLocale
      }
      .store(in: &cancellables)
  }

  @Published private(set) var theme: Theme
  var themePublished: Published<Theme> { _theme }
  var themePublisher: Published<Theme>.Publisher { $theme }
  @Published private(set) var appLocale: AppLocale
  var appLocalePublished: Published<AppLocale> { _appLocale }
  var appLocalePublisher: Published<AppLocale>.Publisher { $appLocale }

  func didChange(userInterfaceStyle: UIUserInterfaceStyle) {
    updateCurrentTheme(userInterfaceStyle: userInterfaceStyle)
  }

  private func updateCurrentTheme(userInterfaceStyle: UIUserInterfaceStyle? = nil) {
    let isDark: Bool
    for window in UIApplication.shared.windows {
      window.overrideUserInterfaceStyle = themeSetting.userInterfaceStyle
    }
    switch themeSetting {
    case .system:
      isDark = (userInterfaceStyle ?? UITraitCollection.current.userInterfaceStyle) == .dark
    case .dark:
      isDark = true
    case .light:
      isDark = false
    }
    theme = isDark ? DarkTheme() : WhiteTheme()
  }

  private var cancellables = Set<AnyCancellable>()
  private var themeSetting: ThemeSetting
}

private extension ThemeSetting {
  var userInterfaceStyle: UIUserInterfaceStyle {
    switch self {
    case .dark:
      return .dark
    case .light:
      return .light
    case .system:
      return .unspecified
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
