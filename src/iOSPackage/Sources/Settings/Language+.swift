import Assets

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

  func orientationName(_ orientation: SettingsState.Orientation?) -> String {
    switch orientation {
    case .none:
      return string(.system)
    case .landscape:
      return string(.orientationLandscape)
    case .portrait:
      return string(.orientationPortrait)
    }
  }
}
