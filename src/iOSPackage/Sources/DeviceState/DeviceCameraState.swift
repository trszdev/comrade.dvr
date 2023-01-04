import ComposableArchitecture
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

public struct DeviceCameraStateEnvironment {
  public init(sessionConfigurator: SessionConfigurator = SessionConfiguratorStub()) {
    self.sessionConfigurator = sessionConfigurator
  }

  public var sessionConfigurator: SessionConfigurator = SessionConfiguratorStub()
}

public let deviceCameraReducer = Reducer<
  DeviceCameraState,
  DeviceCameraAction,
  DeviceCameraStateEnvironment
> { state, action, environment in
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
      do {
        if state.isFrontCamera {
          try await environment.sessionConfigurator.updateFrontCamera(configuration)
        } else {
          try await environment.sessionConfigurator.updateBackCamera(configuration)
        }
      } catch {
        return .merge(.init(value: .receiveConfiguratorError(error)), .init(value: .unlock))
      }
      return .init(value: .unlock)
    }
  case .unlock:
    state.isLocked = false
  case
    .receiveConfiguratorError(SessionConfiguratorError.frontCamera(let errorField)),
    .receiveConfiguratorError(SessionConfiguratorError.frontCamera(let errorField)):
    state.errorFields = [errorField]
  default:
    break
  }
  return .none
}
.binding()
