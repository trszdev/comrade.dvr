import SwiftUI

struct ThemeEnvironmentKey: EnvironmentKey {
  static let defaultValue: Theme = WhiteTheme()
}

struct SafeAreaInsetsKey: EnvironmentKey {
  static var defaultValue: EdgeInsets {
    guard let keyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow) else {
      return EdgeInsets()
    }
    let insets = keyWindow.safeAreaInsets
    return EdgeInsets(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
  }
}
