import ComposableArchitecture
import Device
import CameraKit

public struct DeviceMicrophoneState: Equatable {
  public init(enabled: Bool = false, configuration: MicrophoneConfiguration = .default) {
    self.enabled = enabled
    self.configuration = configuration
  }

  @BindableState public var showAlert: Bool = false
  @BindableState public var enabled: Bool = false
  @BindableState public var configuration: MicrophoneConfiguration = .default
  public var errorFields: Set<PartialKeyPath<MicrophoneConfiguration>> = .init()
  public var isLocked: Bool = false

  public var hasErrors: Bool {
    !errorFields.isEmpty
  }
}

public enum DeviceMicrophoneAction: BindableAction {
  case binding(BindingAction<DeviceMicrophoneState>)
  case sendToConfigurator
  case receiveConfiguratorError(Error)
  case unlock
}

public struct DeviceMicrophoneStateEnvironment {
  public init(sessionConfigurator: SessionConfigurator = SessionConfiguratorStub()) {
    self.sessionConfigurator = sessionConfigurator
  }

  public var sessionConfigurator: SessionConfigurator = SessionConfiguratorStub()
}

public let deviceMicrophoneReducer = Reducer<
  DeviceMicrophoneState,
  DeviceMicrophoneAction,
  DeviceMicrophoneStateEnvironment
> { state, action, environment in
  switch action {
  case .binding(let action):
    guard action.keyPath != \.$showAlert else { return .none }
    return .init(value: .sendToConfigurator)
  case .sendToConfigurator:
    state.isLocked = true
    return .async { [state] in
      let configuration = state.enabled ? state.configuration : nil
      do {
        try await environment.sessionConfigurator.updateMicrophone(configuration)
      } catch {
        return .merge(.init(value: .receiveConfiguratorError(error)), .init(value: .unlock))
      }
      return .init(value: .unlock)
    }
  case .unlock:
    state.isLocked = false
  case .receiveConfiguratorError(SessionConfiguratorError.microphone(let errorField)):
    state.errorFields = [errorField]
  default:
    break
  }
  return .none
}
.binding()
