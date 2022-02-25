import SwiftUI
import ComposableArchitecture
import ComposableArchitectureExtensions

public struct DeviceMicrophoneView: View {
  @ObservedObject var viewStore: ViewStore<DeviceMicrophoneState, DeviceMicrophoneAction>

  public init(store: Store<DeviceMicrophoneState, DeviceMicrophoneAction>) {
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    Color.red
  }
}

struct DeviceMicrophonePreviews: PreviewProvider {
  static var previews: some View {
    DeviceMicrophoneView(store: .init(initialState: .init(), reducer: deviceMicrophoneReducer))
  }
}
