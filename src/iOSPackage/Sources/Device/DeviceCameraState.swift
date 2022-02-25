import ComposableArchitecture

public struct DeviceCameraState: Equatable {
  public init(enabled: Bool = false, configuration: CameraConfiguration = .defaultBackCamera) {
    self.enabled = enabled
    self.configuration = configuration
  }

  @BindableState public var enabled: Bool = false
  @BindableState public var configuration: CameraConfiguration = .defaultBackCamera
}

public enum DeviceCameraAction: BindableAction {
  case binding(BindingAction<DeviceCameraState>)
}

public let deviceCameraReducer = Reducer<DeviceCameraState, DeviceCameraAction, Void> { _, _, _ in
  .none
}
.binding()
