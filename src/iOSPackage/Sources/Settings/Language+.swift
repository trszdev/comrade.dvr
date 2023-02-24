import Assets
import Util

public extension Optional where Wrapped == Language {
  func languageName(_ languageSetting: Language?) -> String {
    switch languageSetting {
    case .none:
      return string(.system)
    case .en:
      return string(.languageEn)
    case .ru:
      return string(.languageRu)
    }
  }

  func pushSectionHeader(_ notificationsEnabled: Bool) -> String {
    notificationsEnabled ? string(.notifications) : "\(string(.notifications)) (\(string(.unavailable)))"
  }

  func appearanceName(_ appearance: Appearance?) -> String {
    switch appearance {
    case .none:
      return string(.system)
    case .dark:
      return string(.darkTheme)
    case .light:
      return string(.lightTheme)
    }
  }
}
