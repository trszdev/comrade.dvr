import SwiftUI

struct ThemeEnvironmentKey: EnvironmentKey {
  static let defaultValue: Theme = WhiteTheme()
}

extension EnvironmentValues {
  var theme: Theme {
    get { self[ThemeEnvironmentKey.self] }
    set { self[ThemeEnvironmentKey.self] = newValue }
  }
}
