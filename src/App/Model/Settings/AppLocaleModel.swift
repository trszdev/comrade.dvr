import Combine

protocol AppLocaleModel {
  var appLocalePublisher: AnyPublisher<AppLocale, Never> { get }
  var appLocale: AppLocale { get }
}

struct AppLocaleModelImpl: AppLocaleModel {
  init(languageSetting: AnySetting<LanguageSetting>) {
    self.languageSetting = languageSetting
    appLocalePublisher = languageSetting.publisher.map(\.appLocale).eraseToAnyPublisher()
  }

  let appLocalePublisher: AnyPublisher<AppLocale, Never>
  var appLocale: AppLocale { languageSetting.value.appLocale }

  private let languageSetting: AnySetting<LanguageSetting>
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
