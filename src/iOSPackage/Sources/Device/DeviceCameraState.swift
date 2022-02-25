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
  case setBitrate(Bitrate)
}

public let deviceCameraReducer = Reducer<DeviceCameraState, DeviceCameraAction, Void> { state, action, _ in
  switch action {
  case .setBitrate(let bitrate):
    state.configuration.bitrate = bitrate
  default:
    break
  }
  return .none
}
.binding()
