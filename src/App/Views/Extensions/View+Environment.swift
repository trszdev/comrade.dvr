import SwiftUI

extension View {
  func environment(_ appLocale: AppLocale) -> some View {
    if let locale = appLocale.currentLocale {
      return AnyView(environment(\.locale, locale))
    }
    return AnyView(self)
  }
}
