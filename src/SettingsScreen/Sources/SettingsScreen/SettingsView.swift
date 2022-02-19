import SwiftUI
import ComposableArchitecture
import Util

public struct SettingsView: View {
  public var store: Store<SettingsState, SettingsAction>
  
  public var body: some View {
    Color.red
  }
}

struct SettingsViewPreviews: PreviewProvider {
  static var previews: some View {
    SettingsView(store: .init(initialState: .init(), reducer: settingsReducer, environment: .init()))
  }
}
