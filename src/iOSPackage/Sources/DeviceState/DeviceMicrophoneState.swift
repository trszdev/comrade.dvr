import ComposableArchitecture
import ComposableArchitectureExtensions
import Device
import CameraKit

public struct DeviceMicrophoneState: Equatable {
  public init(enabled: Bool = false, configuration: MicrophoneConfiguration = .default) {
    self.enabled = enabled
    self.configuration = configuration
  }

  @BindingState public var showAlert: Bool = false
  @BindingState public var enabled: Bool = false
  @BindingState public var configuration: MicrophoneConfiguration = .default
  public var errorFields: Set<PartialKeyPath<MicrophoneConfiguration>> = .init()
  public var isLocked: Bool = false

  public var hasErrors: Bool {
    !errorFields.isEmpty
  }
}

public enum DeviceMicrophoneAction: BindableAction {
  case binding(BindingAction<DeviceMicrophoneState>)
  case onConfigurationChange
}

public let deviceMicrophoneReducer = AnyReducer<DeviceMicrophoneState, DeviceMicrophoneAction, Void> { _, action, _ in
  switch action {
  case .binding(let action):
    guard action.keyPath != \.$showAlert else { return .none }
    return .init(value: .onConfigurationChange)
  default:
    break
  }
  return .none
}
.binding()
