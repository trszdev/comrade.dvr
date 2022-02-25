import ComposableArchitecture

public struct DeviceMicrophoneState: Equatable {
  public init(enabled: Bool = false, configuration: MicrophoneConfiguration = .default) {
    self.enabled = enabled
    self.configuration = configuration
  }

  @BindableState public var enabled: Bool = false
  @BindableState public var configuration: MicrophoneConfiguration = .default
}

public enum DeviceMicrophoneAction: BindableAction {
  case binding(BindingAction<DeviceMicrophoneState>)
}

public let deviceMicrophoneReducer = Reducer<DeviceMicrophoneState, DeviceMicrophoneAction, Void> { _, _, _ in
  .none
}
.binding()
