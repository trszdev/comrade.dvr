import ComposableArchitecture
import Assets

public struct DeviceCameraState: Equatable {
  public init(
    enabled: Bool = false,
    configuration: CameraConfiguration = .defaultBackCamera,
    navigationTitle: L10n = .frontCamera
  ) {
    self.enabled = enabled
    self.configuration = configuration
    self.navigationTitle = navigationTitle
  }

  @BindableState public var showAlert: Bool = false
  @BindableState public var enabled: Bool = false
  @BindableState public var configuration: CameraConfiguration = .defaultBackCamera
  public var navigationTitle: L10n = .frontCamera
  public var errorFields: Set<PartialKeyPath<CameraConfiguration>> = .init()
  public var isLocked: Bool = false

  public var hasErrors: Bool {
    !errorFields.isEmpty
  }
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
