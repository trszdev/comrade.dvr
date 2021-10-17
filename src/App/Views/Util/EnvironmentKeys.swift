import SwiftUI
import Util

struct ThemeEnvironmentKey: EnvironmentKey {
  static let defaultValue: Theme = Default.theme
}

struct GeometryKey: EnvironmentKey {
  static var defaultValue: Geometry {
    guard let keyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow) else {
      return Geometry(size: CGSize(), safeAreaInsets: EdgeInsets())
    }
    let insets = keyWindow.safeAreaInsets
    let safeAreaInsets = EdgeInsets(
      top: insets.top,
      leading: insets.left,
      bottom: insets.bottom,
      trailing: insets.right
    )
    return Geometry(size: keyWindow.bounds.size, safeAreaInsets: safeAreaInsets)
  }
}

struct AppLocaleKey: EnvironmentKey {
  static let defaultValue: AppLocale = Default.appLocale
}
