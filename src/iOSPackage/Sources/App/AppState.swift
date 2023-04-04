import ComposableArchitecture
import Settings
import ComposableArchitectureExtensions
import CommonUI
import History
import Start
import DeviceState
import Paywall
import Permissions
import CameraKit
import Device
import Session
import Util

public struct AppState: Equatable {
  public var settings: Settings = .init()
  public var isPremium: Bool = true
  public var session: Session?

  public var settingsLocalState = SettingsState.LocalState()
  public var settingsState: SettingsState {
    get {
      .init(localState: settingsLocalState, isPremium: isPremium, settings: settings)
    }
    set {
      settings = newValue.settings
      settingsLocalState = newValue.localState
    }
  }
  public var historyState: HistoryState = .init()
  public var frontCameraState: DeviceCameraState = .init(enabled: false, isFrontCamera: true)
  public var backCameraState: DeviceCameraState = .init(enabled: true)
  public var microphoneState: DeviceMicrophoneState = .init(enabled: true)

  public var paywallState: PaywallState = .init()

  public var startLocalState: StartState.LocalState = .init()
  public var startState: StartState {
    get {
      .init(
        localState: startLocalState,
        isPremium: isPremium,
        maxFileLength: settings.maxFileLength,
        frontCameraState: frontCameraState,
        backCameraState: backCameraState,
        microphoneState: microphoneState,
        session: session
      )
    }
    set {
      startLocalState = newValue.localState
      frontCameraState = newValue.frontCameraState
      backCameraState = newValue.backCameraState
      microphoneState = newValue.microphoneState
      session = newValue.session
    }
  }

  public var sessionLocalState = SessionState.LocalState()
  public var sessionState: SessionState {
    get {
      .init(
        backCameraPreviewView: session?.backCameraPreviewView,
        frontCameraPreviewView: session?.frontCameraPreviewView,
        localState: sessionLocalState
      )
    }
    set {
      sessionLocalState = newValue.localState
    }
  }
}

public enum AppAction {
  case settingsAction(SettingsAction)
  case historyAction(HistoryAction)
  case startAction(StartAction)
  case paywallAction(PaywallAction)
  case sessionAction(SessionAction)
}

public struct AppEnvironment {
  public var routing: Routing = RoutingStub()
  public var settingsRepository: SettingsRepository = SettingsRepositoryStub()
  public var permissionDialogPresenting: PermissionDialogPresenting = PermissionDialogPresentingStub()
  public var permissionChecker: PermissionChecker = .live
  public var sessionConfigurator: SessionConfigurator = SessionConfiguratorStub.shared
  public var deviceConfigurationRepository: DeviceConfigurationRepository = DeviceConfigurationRepositoryStub()
  public var historyRepository: HistoryRepository = HistoryRepositoryStub.shared
  public var datedFileManager: DatedFileManager = DatedFileManagerStub()
  public var cameraKitService: CameraKitService = CameraKitServiceStub.shared
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  .init { _, action, environment in
    switch action {
    case .settingsAction(.clearAllRecordings):
      return .task {
        environment.datedFileManager.removeFiles(toFit: .zero)
        await environment.routing.tabRouting?.selectHistory()
      }
    default:
      break
    }
    return .none
  },

  settingsReducer.pullback(state: \.settingsState, action: /AppAction.settingsAction) {
    .init(
      repository: $0.settingsRepository,
      routing: $0.routing,
      permissionDialogPresenting: $0.permissionDialogPresenting,
      permissionChecker: $0.permissionChecker
    )
  },

  historyReducer.pullback(state: \.historyState, action: /AppAction.historyAction) {
    .init(routing: $0.routing, repository: $0.historyRepository)
  },

  startReducer.pullback(state: \.startState, action: /AppAction.startAction) {
    .init(
      routing: $0.routing,
      permissionDialogPresenting: $0.permissionDialogPresenting,
      deviceConfigurationRepository: $0.deviceConfigurationRepository,
      datedFileManager: $0.datedFileManager,
      cameraKitService: $0.cameraKitService
    )
  },

  paywallReducer.pullback(state: \.paywallState, action: /AppAction.paywallAction),

  sessionReducer.pullback(state: \.sessionState, action: /AppAction.sessionAction) {
    .init(routing: $0.routing)
  }
)
