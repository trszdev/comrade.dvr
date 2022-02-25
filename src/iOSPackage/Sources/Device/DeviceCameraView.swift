import SwiftUI
import ComposableArchitecture

public struct DeviceCameraView: View {
  @ObservedObject var viewStore: ViewStore<DeviceCameraState, DeviceCameraAction>

  public init(store: Store<DeviceCameraState, DeviceCameraAction>) {
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    Color.red
  }
}

struct DeviceCameraPreviews: PreviewProvider {
  static var previews: some View {
    DeviceCameraView(store: .init(initialState: .init(), reducer: deviceCameraReducer))
  }
}
