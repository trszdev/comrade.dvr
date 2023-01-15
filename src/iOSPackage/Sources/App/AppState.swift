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

public struct AppState: Equatable {
  public var settings: Settings = .init()
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
  public var isPremium: Bool = true

  public var paywallState: PaywallState = .init()

  public var startLocalState: StartState.LocalState = .init()
  public var startState: StartState {
    get {
      .init(
        localState: startLocalState,
        isPremium: isPremium,
        frontCameraState: frontCameraState,
        backCameraState: backCameraState,
        microphoneState: microphoneState
      )
    }
    set {
      startLocalState = newValue.localState
      frontCameraState = newValue.frontCameraState
      backCameraState = newValue.backCameraState
      microphoneState = newValue.microphoneState
    }
  }
}

public enum AppAction {
  case settingsAction(SettingsAction)
  case historyAction(HistoryAction)
  case startAction(StartAction)
  case paywallAction(PaywallAction)
}

public struct AppEnvironment {
  public var routing: Routing = RoutingStub()
  public var settingsRepository: SettingsRepository = SettingsRepositoryStub()
  public var permissionDialogPresenting: PermissionDialogPresenting = PermissionDialogPresentingStub()
  public var permissionChecker: PermissionChecker = .live
  public var sessionConfigurator: SessionConfigurator = SessionConfiguratorStub()
  public var deviceConfigurationRepository: DeviceConfigurationRepository = DeviceConfigurationRepositoryStub()
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  .init { _, action, environment in
    switch action {
    case .settingsAction(.clearAllRecordings):
      return .task {
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
    .init(routing: $0.routing)
  },

  startReducer.pullback(state: \.startState, action: /AppAction.startAction) {
    .init(
      routing: $0.routing,
      permissionDialogPresenting: $0.permissionDialogPresenting,
      deviceConfigurationRepository: $0.deviceConfigurationRepository
    )
  },

  paywallReducer.pullback(state: \.paywallState, action: /AppAction.paywallAction)
)
