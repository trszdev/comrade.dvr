import Foundation
import SwiftUI
import Assets

struct MainView: View {
  @Environment(\.language) var language
  @Environment(\.appearance) var appearance

  var body: some View {
    VStack {
      Text(language.string(.cameraPermissionAlertText))

      appearance.color(.accentColorDark)
    }
  }
}
