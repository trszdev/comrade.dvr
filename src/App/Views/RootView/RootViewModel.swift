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
    appLocaleModel: AppLocaleModel,
    application: UIApplication
  ) {
    self.themeSetting = themeSetting.value
    self.theme = WhiteTheme()
    self.appLocale = appLocaleModel.appLocale
    self.application = application
    updateCurrentTheme()
    themeSetting.publisher
      .sink { [weak self] newThemeSetting in
        guard let self = self else { return }
        self.themeSetting = newThemeSetting
        self.updateCurrentTheme()
      }
      .store(in: &cancellables)
    appLocaleModel.appLocalePublisher
      .assign(to: \.appLocale, on: self)
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
    for window in application.windows {
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

  private let application: UIApplication
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
