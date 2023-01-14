import ComposableArchitecture
import ComposableArchitectureExtensions
import Assets
import Device
import CameraKit

public struct DeviceCameraState: Equatable {
  public init(
    enabled: Bool = false,
    isFrontCamera: Bool = false,
    configuration: CameraConfiguration? = nil
  ) {
    self.enabled = enabled
    self.isFrontCamera = isFrontCamera
    self.configuration = configuration ?? (isFrontCamera ? .defaultFrontCamera : .defaultBackCamera)
  }

  @BindableState public var showAlert: Bool = false
  @BindableState public var enabled: Bool = false
  @BindableState public var configuration: CameraConfiguration = .defaultBackCamera
  public var isFrontCamera: Bool = false
  public var errorFields: Set<PartialKeyPath<CameraConfiguration>> = .init()
  public var isLocked: Bool = false

  public var deviceName: L10n {
    isFrontCamera ? .frontCamera : .backCamera
  }

  public var hasErrors: Bool {
    !errorFields.isEmpty
  }
}

public enum DeviceCameraAction: BindableAction {
  case binding(BindingAction<DeviceCameraState>)
  case sendToConfigurator
  case receiveConfiguratorError(Error)
  case unlock
  case setBitrate(Bitrate)
}

public let deviceCameraReducer = Reducer<DeviceCameraState, DeviceCameraAction, Void> { state, action, _ in
  switch action {
  case .binding(let action):
    guard action.keyPath != \.$showAlert else { return .none }
    return .init(value: .sendToConfigurator)
  case .setBitrate(let bitrate):
    state.configuration.bitrate = bitrate
    return .init(value: .sendToConfigurator)
  case .sendToConfigurator:
    state.isLocked = true
    return .async { [state] in
      let configuration = state.enabled ? state.configuration : nil
      return .init(value: .unlock)
    }
  case .unlock:
    state.isLocked = false
  default:
    break
  }
  return .none
}
.binding()
