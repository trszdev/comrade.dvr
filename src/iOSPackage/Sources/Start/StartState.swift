import ComposableArchitecture
import Device
import ComposableArchitectureExtensions
import CommonUI
import Combine
import Util
import Permissions
import DeviceState

public struct StartState: Equatable {
  public struct LocalState: Equatable {
    public init() {}
    public var selectedFrontCamera: Bool = false
    public var autostartSecondsRemaining: Int?
  }

  public var localState: LocalState = .init()
  public var isPremium: Bool = false

  public var selectedCameraState: DeviceCameraState {
    get {
      localState.selectedFrontCamera ? frontCameraState : backCameraState
    }
    set {
      if localState.selectedFrontCamera {
        frontCameraState = newValue
      } else {
        backCameraState = newValue
      }
    }
  }
  public var frontCameraState: DeviceCameraState = .init(enabled: false, configuration: .defaultFrontCamera)
  public var backCameraState: DeviceCameraState = .init(enabled: true, configuration: .defaultBackCamera)
  public var microphoneState: DeviceMicrophoneState = .init(enabled: true, configuration: .default)
  public var occupiedSpace: FileSize = .zero
  public var lastCapture: Date?
  public var isLocked: Bool {
    backCameraState.isLocked || frontCameraState.isLocked || microphoneState.isLocked
  }

  public init(
    localState: LocalState = .init(),
    isPremium: Bool = false,
    frontCameraState: DeviceCameraState = .init(enabled: false, configuration: .defaultFrontCamera),
    backCameraState: DeviceCameraState = .init(enabled: true, configuration: .defaultBackCamera),
    microphoneState: DeviceMicrophoneState = .init(enabled: true, configuration: .default),
    occupiedSpace: FileSize = .zero,
    lastCapture: Date? = nil
  ) {
    self.localState = localState
    self.isPremium = isPremium
    self.frontCameraState = frontCameraState
    self.backCameraState = backCameraState
    self.microphoneState = microphoneState
    self.occupiedSpace = occupiedSpace
    self.lastCapture = lastCapture
  }
}

public enum StartAction {
  case onAppear
  case onDisappear
  case start
  case tapFrontCamera
  case tapBackCamera
  case tapMicrophone
  case autostart
  case autostartTick
  case cancelAutostart
  case forceStart
  case deviceConfigurationLoaded(DeviceConfiguration)
  case deviceCameraAction(DeviceCameraAction)
  case deviceMicrophoneAction(DeviceMicrophoneAction)
}

public struct StartEnvironment {
  public init(
    routing: Routing = RoutingStub(),
    mainQueue: AnySchedulerOf<DispatchQueue> = .main,
    permissionDialogPresenting: PermissionDialogPresenting = PermissionDialogPresentingStub(),
    permissionChecker: PermissionChecker = .live,
    deviceConfigurationRepository: DeviceConfigurationRepository = DeviceConfigurationRepositoryStub()
  ) {
    self.routing = routing
    self.mainQueue = mainQueue
    self.permissionDialogPresenting = permissionDialogPresenting
    self.permissionChecker = permissionChecker
    self.deviceConfigurationRepository = deviceConfigurationRepository
  }

  public var routing: Routing = RoutingStub()
  public var mainQueue: AnySchedulerOf<DispatchQueue> = .main
  public var permissionDialogPresenting: PermissionDialogPresenting = PermissionDialogPresentingStub()
  public var permissionChecker: PermissionChecker = .live
  public var deviceConfigurationRepository: DeviceConfigurationRepository = DeviceConfigurationRepositoryStub()
}

public let startReducer = Reducer<StartState, StartAction, StartEnvironment>.combine([
  .init { state, action, environment in
    switch action {
    case .tapFrontCamera:
      state.localState.selectedFrontCamera = true
    case .tapBackCamera:
      state.localState.selectedFrontCamera = false
    case .deviceCameraAction(.sendToConfigurator), .deviceMicrophoneAction(.sendToConfigurator):
      let deviceConfiguration = DeviceConfiguration(
        frontCamera: state.frontCameraState.configuration,
        frontCameraEnabled: state.frontCameraState.enabled,
        backCamera: state.backCameraState.configuration,
        backCameraEnabled: state.backCameraState.enabled,
        microphone: state.microphoneState.configuration,
        microphoneEnabled: state.microphoneState.enabled
      )
      return .task {
        await environment.deviceConfigurationRepository.save(deviceConfiguration: deviceConfiguration)
      }
    default:
      break
    }
    return .none
  },
  .init { state, action, environment in
    switch action {
    case .autostartTick:
      if let seconds = state.localState.autostartSecondsRemaining, seconds > 1 {
        state.localState.autostartSecondsRemaining = seconds - 1
        return .init(value: .autostartTick, delay: .seconds(1), scheduler: environment.mainQueue)
          .cancellable(id: AutostartTimerID())
      } else {
        state.localState.autostartSecondsRemaining = nil
        return .init(value: .start)
      }
    case .autostart:
      if environment.permissionChecker.hasStartPermissions {
        state.localState.autostartSecondsRemaining = 4
        return .init(value: .autostartTick)
      }
    case .tapFrontCamera, .tapBackCamera:
      state.localState.autostartSecondsRemaining = nil
      return .merge(
        .task {
          let hasAccess = await environment.permissionDialogPresenting.tryPresentDialog(for: .camera)
          guard hasAccess else { return }
          await environment.routing.tabRouting?.startRouting?.openDeviceCamera(animated: true)
        },
        .cancel(id: AutostartTimerID())
      )
    case .tapMicrophone:
      state.localState.autostartSecondsRemaining = nil
      return .merge(
        .task {
          let hasAccess = await environment.permissionDialogPresenting.tryPresentDialog(for: .microphone)
          guard hasAccess else { return }
          await environment.routing.tabRouting?.startRouting?.openDeviceMicrophone(animated: true)
        },
        .cancel(id: AutostartTimerID())
      )
    case .start:
      if state.localState.autostartSecondsRemaining != nil {
        state.localState.autostartSecondsRemaining = nil
        return .cancel(id: AutostartTimerID())
      } else {
        return .async {
          if environment.permissionChecker.hasStartPermissions {
            return .init(value: .forceStart)
          }
          await environment.routing.tabRouting?.startRouting?.showPermissions(animated: true)
          return .none
        }
      }
    case .forceStart:
      return .task {
        await environment.routing.selectSession(animated: true)
      }
    case let .deviceConfigurationLoaded(configuration):
      state.frontCameraState = .init(
        enabled: configuration.frontCameraEnabled,
        isFrontCamera: true,
        configuration: configuration.frontCamera
      )
      state.backCameraState = .init(enabled: configuration.backCameraEnabled, configuration: configuration.backCamera)
      state.microphoneState = .init(enabled: configuration.microphoneEnabled, configuration: configuration.microphone)
    default:
      break
    }
    return .none
  },

  deviceCameraReducer.pullback(state: \.selectedCameraState, action: /StartAction.deviceCameraAction),

  deviceMicrophoneReducer.pullback(state: \.microphoneState, action: /StartAction.deviceMicrophoneAction),

])

private struct AutostartTimerID: Hashable {}

private extension PermissionChecker {
  var hasStartPermissions: Bool {
    let hasCameraAccess = authorized(.camera) == true
    let hasMicrophoneAccess = authorized(.microphone) == true
    let hasDeterminedNotification = authorized(.notification) != nil
    return hasCameraAccess && hasMicrophoneAccess && hasDeterminedNotification
  }
}
