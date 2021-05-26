import SwiftUI

extension EnvironmentValues {
  var theme: Theme {
    get { self[ThemeEnvironmentKey.self] }
    set { self[ThemeEnvironmentKey.self] = newValue }
  }

  var geometry: Geometry {
    get { self[GeometryKey.self] }
    set { self[GeometryKey.self] = newValue }
  }

  var locale: Locale {
    get { self[LocaleKey.self] }
    set { self[LocaleKey.self] = newValue }
  }
}
