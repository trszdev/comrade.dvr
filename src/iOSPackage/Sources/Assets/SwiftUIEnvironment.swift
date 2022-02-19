import SwiftUI

private struct LanguageKey: EnvironmentKey {
  static let defaultValue: Language? = nil
}

private struct AppearanceKey: EnvironmentKey {
  static let defaultValue: Appearance? = nil
}

public extension EnvironmentValues {
  var language: Language? {
    get { self[LanguageKey.self] }
    set { self[LanguageKey.self] = newValue }
  }

  var appearance: Appearance? {
    get { self[AppearanceKey.self] }
    set { self[AppearanceKey.self] = newValue }
  }
}
