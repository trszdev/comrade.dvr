import ComposableArchitecture
import ComposableArchitectureExtensions
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
  case onConfigurationChange
}

public let deviceMicrophoneReducer = Reducer<DeviceMicrophoneState, DeviceMicrophoneAction, Void> { _, action, _ in
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
