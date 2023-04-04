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

  @BindableState public var localState: LocalState = .init()
  public var session: Session?
  public var isPremium: Bool = false
  public var maxFileLength: TimeInterval = .seconds(1)
  public var orientation: Orientation = .portrait

  var deviceConfiguration: CameraKit.DeviceConfiguration {
    .init(
      frontCamera: (frontCameraState.enabled && !frontCameraState.isLocked) ? frontCameraState.configuration : nil,
      backCamera: (backCameraState.enabled && !backCameraState.isLocked) ? backCameraState.configuration : nil,
      microphone: (microphoneState.enabled && !microphoneState.isLocked) ? microphoneState.configuration : nil,
      maxFileLength: maxFileLength,
      orientation: orientation
    )
  }

  mutating func recreateSession() {
    session = deviceConfiguration.makeSession()
  }

  var canStart: Bool {
    if frontCameraState.hasErrors || backCameraState.hasErrors || microphoneState.hasErrors {
      return false
    }
    let frontCameraEnabled = !frontCameraState.isLocked && frontCameraState.enabled
    let backCameraEnabled = !backCameraState.isLocked && backCameraState.enabled
    let microphoneEnabled = !microphoneState.isLocked && microphoneState.enabled
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
  public var frontCameraState: DeviceCameraState = .init(enabled: false, configuration: .defaultFrontCamera)
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
  case deviceConfigurationLoaded(Device.DeviceConfiguration)
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
    cameraKitService: CameraKitService = CameraKitServiceStub.shared
  ) {
    self.routing = routing
    self.mainQueue = mainQueue
    self.permissionDialogPresenting = permissionDialogPresenting
    self.permissionChecker = permissionChecker
    self.deviceConfigurationRepository = deviceConfigurationRepository
    self.datedFileManager = datedFileManager
    self.cameraKitService = cameraKitService
  }

  public var routing: Routing = RoutingStub()
  public var mainQueue: AnySchedulerOf<DispatchQueue> = .main
  public var permissionDialogPresenting: PermissionDialogPresenting = PermissionDialogPresentingStub()
  public var permissionChecker: PermissionChecker = .live
  public var deviceConfigurationRepository: DeviceConfigurationRepository = DeviceConfigurationRepositoryStub()
  public var datedFileManager: DatedFileManager = DatedFileManagerStub()
  public var cameraKitService: CameraKitService = CameraKitServiceStub.shared
  let discovery = Discovery()
}

public let startReducer = Reducer<StartState, StartAction, StartEnvironment>.combine([
  .init { state, action, environment in
    switch action {
    case .tapFrontCamera:
      state.localState.selectedFrontCamera = true
    case .tapBackCamera:
      state.localState.selectedFrontCamera = false
    case .deviceCameraAction(.onConfigurationChange), .deviceMicrophoneAction(.onConfigurationChange):
      guard environment.cameraKitService.tryConfigure(using: &state) else { return .none }
      let deviceConfiguration = Device.DeviceConfiguration(
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
          .cancellable(id: AutostartTimerID())
      } else {
        state.localState.autostartSecondsRemaining = nil
        return .merge(
          .init(value: .tapStart),
          .cancel(id: AutostartTimerID())
        )
      }
    case .autostart:
      if environment.permissionChecker.hasStartPermissions {
        guard environment.cameraKitService.tryConfigure(using: &state) else { return .none }
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
    case .tapStart:
      if state.localState.autostartSecondsRemaining != nil {
        state.localState.autostartSecondsRemaining = nil
        return .cancel(id: AutostartTimerID())
      } else {
        if environment.permissionChecker.hasStartPermissions {
          return .init(value: .configureAndPlay)
        } else {
          return .async {
            await environment.routing.tabRouting?.startRouting?.showPermissions(animated: true)
            await environment.routing.tabRouting?.startRouting?.permissionRouting?.waitToClose()
            guard environment.permissionChecker.hasStartPermissions else { return .none }
            return .init(value: .configureAndPlay)
          }
        }
      }
    case .configureAndPlay:
      guard environment.cameraKitService.tryConfigure(using: &state) else { return .none }
      environment.cameraKitService.play()
      let config = state.deviceConfiguration
      return .task {
        await environment.routing.selectSession(orientation: config.orientation.interfaceOrientation, animated: true)
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
.binding()

private struct AutostartTimerID: Hashable {}

private extension PermissionChecker {
  var hasStartPermissions: Bool {
    let hasCameraAccess = authorized(.camera) == true
    let hasMicrophoneAccess = authorized(.microphone) == true
    let hasDeterminedNotification = authorized(.notification) != nil
    return hasCameraAccess && hasMicrophoneAccess && hasDeterminedNotification
  }
}

private extension CameraKitService {
  func tryConfigure(using startState: inout StartState) -> Bool {
    startState.recreateSession()
    guard let session = startState.session else {
      log.crit("no session found")
      return false
    }
    do {
      try configure(session: session, deviceConfiguration: startState.deviceConfiguration)
      return true
    } catch {
      startState.handleError(error)
      return false
    }
  }
}
