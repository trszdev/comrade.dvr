import SwiftUI

struct SettingsView: View {
  var body: some View {
    Color.green.ignoresSafeArea()
  }
}

#if DEBUG

struct SettingsViewPreview: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}

#endif
