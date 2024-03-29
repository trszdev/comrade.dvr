import ComposableArchitecture
import Device
import ComposableArchitectureExtensions
import CommonUI
import Combine
import Util
import Permissions
import DeviceState
import CameraKit
import SwiftUI

public struct StartState: Equatable {
  public struct LocalState: Equatable {
    public init() {}
    public var selectedFrontCamera: Bool = false
    public var autostartSecondsRemaining: Int?
    public var occupiedSpace: FileSize = .zero
    public var lastCapture: Date?
    public var orientation: Orientation = .portrait
    public var alertError: StartStateError?
  }

  @BindingState public var localState: LocalState = .init()
  public var session: Session?
  public var isPremium: Bool = false
  public var maxFileLength: TimeInterval = .seconds(1)

  public var deviceConfiguration: CameraKit.DeviceConfiguration {
    .init(
      frontCamera: (frontCameraState.enabled && !frontCameraState.isLocked) ? frontCameraState.configuration : nil,
      backCamera: (backCameraState.enabled && !backCameraState.isLocked) ? backCameraState.configuration : nil,
      microphone: (microphoneState.enabled && !microphoneState.isLocked) ? microphoneState.configuration : nil,
      maxFileLength: maxFileLength,
      orientation: localState.orientation
    )
  }

  mutating func recreateSession() {
    log.debug()
    session = deviceConfiguration.makeSession()
  }

  var canStart: Bool {
    if frontCameraState.hasErrors || backCameraState.hasErrors || microphoneState.hasErrors {
      return false
    }
    let frontCameraEnabled = !frontCameraState.isLocked && frontCameraState.enabled
    let backCameraEnabled = !backCameraState.isLocked && backCameraState.enabled
    // let microphoneEnabled = !microphoneState.isLocked && microphoneState.enabled
    return frontCameraEnabled || backCameraEnabled
  }

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
  public var frontCameraState: DeviceCameraState = .init(
    enabled: false,
    isFrontCamera: true,
    configuration: .defaultFrontCamera
  )
  public var backCameraState: DeviceCameraState = .init(enabled: true, configuration: .defaultBackCamera)
  public var microphoneState: DeviceMicrophoneState = .init(enabled: true, configuration: .default)

  public init(
    localState: LocalState = .init(),
    isPremium: Bool = false,
    maxFileLength: TimeInterval = .seconds(1),
    frontCameraState: DeviceCameraState = .init(enabled: false, configuration: .defaultFrontCamera),
    backCameraState: DeviceCameraState = .init(enabled: true, configuration: .defaultBackCamera),
    microphoneState: DeviceMicrophoneState = .init(enabled: true, configuration: .default),
    session: Session? = nil
  ) {
    self.localState = localState
    self.isPremium = isPremium
    self.maxFileLength = maxFileLength
    self.frontCameraState = frontCameraState
    self.backCameraState = backCameraState
    self.microphoneState = microphoneState
    self.session = session
  }

  mutating func handleError(_ error: Error) {
    guard let error = error as? SessionConfiguratorError else {
      localState.alertError = .unexpectedError(error.localizedDescription)
      return
    }
    switch error {
    case let .camera(.fields(frontCameraFields), .fields(backCameraFields)):
      frontCameraState.errorFields = Set(frontCameraFields)
      backCameraState.errorFields = Set(backCameraFields)
    case let .camera(.fields(frontCameraFields), _):
      frontCameraState.errorFields = Set(frontCameraFields)
    case let .camera(_, .fields(backCameraFields)):
      backCameraState.errorFields = Set(backCameraFields)
    case let .microphone(.fields(fields)):
      microphoneState.errorFields = Set(fields)
    case .microphone(.runtimeError):
      localState.alertError = .microphoneRuntimeError
    case .camera(.connectionError, _):
      localState.alertError = .frontCameraRuntimeError
    case .camera(_, .connectionError):
      localState.alertError = .backCameraRuntimeError
    default:
      break
    }
  }
}

public enum StartAction: BindableAction {
  case onAppear
  case onDisappear
  case onOrientationChange(Orientation)
  case tapFrontCamera
  case tapBackCamera
  case tapMicrophone
  case tapStart
  case autostart
  case autostartTick
  case configureAndPlay
  case deviceConfigurationLoaded(Device.DeviceConfiguration, DeviceConfigurationIndex)
  case deviceCameraAction(DeviceCameraAction)
  case deviceMicrophoneAction(DeviceMicrophoneAction)
  case binding(BindingAction<StartState>)
}

public struct StartEnvironment {
  public init(
    routing: Routing = RoutingStub(),
    mainQueue: AnySchedulerOf<DispatchQueue> = .main,
    permissionDialogPresenting: PermissionDialogPresenting = PermissionDialogPresentingStub(),
    permissionChecker: PermissionChecker = .live,
    deviceConfigurationRepository: DeviceConfigurationRepository = DeviceConfigurationRepositoryStub(),
    datedFileManager: DatedFileManager = DatedFileManagerStub(),
    sessionConfigurator: SessionConfigurator = SessionConfiguratorStub.shared
  ) {
    self.routing = routing
    self.mainQueue = mainQueue
    self.permissionDialogPresenting = permissionDialogPresenting
    self.permissionChecker = permissionChecker
    self.deviceConfigurationRepository = deviceConfigurationRepository
    self.datedFileManager = datedFileManager
    self.sessionConfigurator = sessionConfigurator
  }

  public var routing: Routing = RoutingStub()
  public var mainQueue: AnySchedulerOf<DispatchQueue> = .main
  public var permissionDialogPresenting: PermissionDialogPresenting = PermissionDialogPresentingStub()
  public var permissionChecker: PermissionChecker = .live
  public var deviceConfigurationRepository: DeviceConfigurationRepository = DeviceConfigurationRepositoryStub()
  public var datedFileManager: DatedFileManager = DatedFileManagerStub()
  public var sessionConfigurator: SessionConfigurator = SessionConfiguratorStub.shared
  let discovery = Discovery()
}

public let startReducer = AnyReducer<StartState, StartAction, StartEnvironment>.combine([
  .init { state, action, environment in
    switch action {
    case .tapFrontCamera:
      state.localState.selectedFrontCamera = true
    case .tapBackCamera:
      state.localState.selectedFrontCamera = false
    case .deviceCameraAction(.onConfigurationChange), .deviceMicrophoneAction(.onConfigurationChange):
      environment.sessionConfigurator.tryConfigure(using: &state)
      let deviceConfiguration = Device.DeviceConfiguration(
        frontCamera: state.frontCameraState.configuration,
        frontCameraEnabled: state.frontCameraState.enabled,
        backCamera: state.backCameraState.configuration,
        backCameraEnabled: state.backCameraState.enabled,
        microphone: state.microphoneState.configuration,
        microphoneEnabled: state.microphoneState.enabled
      )
      return .fireAndForget {
        await environment.deviceConfigurationRepository.save(deviceConfiguration: deviceConfiguration)
      }
    default:
      break
    }
    return .none
  },
  .init { state, action, environment in
    switch action {
    case .onAppear:
      let entries = environment.datedFileManager.entries()
      state.localState.occupiedSpace = environment.datedFileManager.totalFileSize
      state.localState.lastCapture = environment.datedFileManager.entries().lazy.map(\.date).min()
      state.backCameraState.isLocked = environment.discovery.backCameras.isEmpty
      state.frontCameraState.isLocked = environment.discovery.frontCameras.isEmpty
      state.microphoneState.isLocked = environment.discovery.builtInMic == nil
    case let .onOrientationChange(orientation):
      state.localState.orientation = orientation
    case .autostartTick:
      if let seconds = state.localState.autostartSecondsRemaining, seconds > 1 {
        state.localState.autostartSecondsRemaining = seconds - 1
        return .init(value: .autostartTick, delay: .seconds(1), scheduler: environment.mainQueue)
          .cancellable(id: AutostartTimerID(), cancelInFlight: true)
      } else {
        state.localState.autostartSecondsRemaining = nil
        return .merge(
          .init(value: .tapStart),
          .cancel(id: AutostartTimerID())
        )
      }
    case .autostart:
      if environment.permissionChecker.hasStartPermissions {
        guard environment.sessionConfigurator.tryConfigure(using: &state) else { return .none }
        state.localState.autostartSecondsRemaining = 4
        return .init(value: .autostartTick)
      }
    case .tapFrontCamera, .tapBackCamera:
      state.localState.autostartSecondsRemaining = nil
      return .merge(
        .fireAndForget {
          let hasAccess = await environment.permissionDialogPresenting.tryPresentDialog(for: .camera)
          guard hasAccess else { return }
          await environment.routing.tabRouting?.startRouting?.openDeviceCamera(animated: true)
        },
        .cancel(id: AutostartTimerID())
      )
    case .tapMicrophone:
      state.localState.autostartSecondsRemaining = nil
      return .merge(
        .fireAndForget {
          let hasAccess = await environment.permissionDialogPresenting.tryPresentDialog(for: .microphone)
          guard hasAccess else { return }
          await environment.routing.tabRouting?.startRouting?.openDeviceMicrophone(animated: true)
        },
        .cancel(id: AutostartTimerID())
      )
    case .tapStart:
      if state.localState.autostartSecondsRemaining != nil {
        state.localState.autostartSecondsRemaining = nil
        return .cancel(id: AutostartTimerID())
      } else {
        if environment.permissionChecker.hasStartPermissions {
          return .init(value: .configureAndPlay)
        } else {
          return .run { send in
            await environment.routing.tabRouting?.startRouting?.showPermissions(animated: true)
            await environment.routing.tabRouting?.startRouting?.permissionRouting?.waitToClose()
            guard environment.permissionChecker.hasStartPermissions else { return }
            await send.send(.configureAndPlay)
          }
        }
      }
    case .configureAndPlay:
      guard environment.sessionConfigurator.tryConfigure(using: &state) else { return .none }
      let config = state.deviceConfiguration
      return .fireAndForget {
        await environment.routing.selectSession(orientation: config.orientation.interfaceOrientation, animated: true)
      }
    case let .deviceConfigurationLoaded(configuration, index):
      state.frontCameraState.enabled = configuration.frontCameraEnabled
      state.frontCameraState.configuration = configuration.frontCamera
      state.frontCameraState.index = index.frontCamera
      state.backCameraState.enabled = configuration.backCameraEnabled
      state.backCameraState.configuration = configuration.backCamera
      state.backCameraState.index = index.backCamera
      state.microphoneState.enabled = configuration.microphoneEnabled
      state.microphoneState.configuration = configuration.microphone
    default:
      break
    }
    return .none
  },

  deviceCameraReducer.pullback(state: \.selectedCameraState, action: /StartAction.deviceCameraAction) {
    .init(mainQueue: $0.mainQueue)
  },

  deviceMicrophoneReducer.pullback(state: \.microphoneState, action: /StartAction.deviceMicrophoneAction),

])
.binding()

private struct AutostartTimerID: Hashable {}

private extension PermissionChecker {
  var hasStartPermissions: Bool {
    let hasCameraAccess = authorized(.camera) == true
    let hasMicrophoneAccess = authorized(.microphone) == true
    // let hasDeterminedNotification = authorized(.notification) != nil
    return hasCameraAccess && hasMicrophoneAccess
  }
}

private extension SessionConfigurator {
  @discardableResult
  func tryConfigure(using startState: inout StartState) -> Bool {
    startState.recreateSession()
    guard let session = startState.session else {
      log.crit("no session found")
      return false
    }
    do {
      log.debug("configuring \(session)")
      try configure(session: session, deviceConfiguration: startState.deviceConfiguration)
      return true
    } catch {
      log.warn(error: error)
      startState.handleError(error)
      return false
    }
  }
}
