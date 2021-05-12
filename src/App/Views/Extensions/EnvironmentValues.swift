import SwiftUI

extension EnvironmentValues {
  var theme: Theme {
    get { self[ThemeEnvironmentKey.self] }
    set { self[ThemeEnvironmentKey.self] = newValue }
  }

  var safeAreaInsets: EdgeInsets {
    self[SafeAreaInsetsKey.self]
  }
}
