import ComposableArchitecture
import Device
import CommonUI
import Combine
import Util
import Permissions
import DeviceState

public struct StartState: Equatable {
  public struct LocalState: Equatable {
    public init() {}
    public var autostartSecondsRemaining: Int?
  }

  public var localState: LocalState = .init()
  public var isPremium: Bool = false
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
}

public struct StartEnvironment {
  public init(
    routing: Routing = RoutingStub(),
    mainQueue: AnySchedulerOf<DispatchQueue> = .main,
    permissionDialogPresenting: PermissionDialogPresenting = PermissionDialogPresentingStub(),
    permissionChecker: PermissionChecker = .live
  ) {
    self.routing = routing
    self.mainQueue = mainQueue
    self.permissionDialogPresenting = permissionDialogPresenting
    self.permissionChecker = permissionChecker
  }

  public var routing: Routing = RoutingStub()
  public var mainQueue: AnySchedulerOf<DispatchQueue> = .main
  public var permissionDialogPresenting: PermissionDialogPresenting = PermissionDialogPresentingStub()
  public var permissionChecker: PermissionChecker = .live
}

public let startReducer = Reducer<StartState, StartAction, StartEnvironment> { state, action, environment in
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
  default:
    break
  }
  return .none
}

private struct AutostartTimerID: Hashable {}

private extension PermissionChecker {
  var hasStartPermissions: Bool {
    let hasCameraAccess = authorized(.camera) == true
    let hasMicrophoneAccess = authorized(.microphone) == true
    let hasDeterminedNotification = authorized(.notification) != nil
    return hasCameraAccess && hasMicrophoneAccess && hasDeterminedNotification
  }
}
