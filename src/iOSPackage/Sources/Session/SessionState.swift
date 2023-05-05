import ComposableArchitecture
import CommonUI
import ComposableArchitectureExtensions
import UIKit
import CameraKit
import Device
import Util

public struct SessionState: Equatable {
  public struct LocalState: Equatable {
    public init(hasSwitchedCameras: Bool = false, alertError: SessionMonitorError? = nil) {
      self.hasSwitchedCameras = hasSwitchedCameras
      self.alertError = alertError
    }

    public var hasSwitchedCameras = false
    public var alertError: SessionMonitorError?
  }

  public init(
    backCameraPreviewView: UIView? = nil,
    frontCameraPreviewView: UIView? = nil,
    orientation: Orientation = .portrait,
    localState: LocalState = LocalState()
  ) {
    self.backCameraPreviewView = backCameraPreviewView
    self.frontCameraPreviewView = frontCameraPreviewView
    self.orientation = orientation
    self.localState = localState
  }

  public var backCameraPreviewView: UIView?
  public var frontCameraPreviewView: UIView?
  public var orientation: Orientation = .portrait
  @BindingState public var localState = LocalState()

  var mainCameraPreviewView: UIView? {
    if hasTwoCameras {
      return localState.hasSwitchedCameras ? frontCameraPreviewView : backCameraPreviewView
    } else {
      return backCameraPreviewView ?? frontCameraPreviewView
    }
  }

  var secondaryCameraPreviewView: UIView? {
    localState.hasSwitchedCameras ? backCameraPreviewView : frontCameraPreviewView
  }

  var hasTwoCameras: Bool {
    backCameraPreviewView != nil && frontCameraPreviewView != nil
  }
}

public enum SessionAction: BindableAction {
  case onAppear
  case onDisappear
  case showError(SessionMonitorError)
  case tapBack
  case switchCameras
  case binding(BindingAction<SessionState>)
}

public struct SessionEnvironment {
  public init(
    routing: Routing = RoutingStub(),
    player: SessionPlayer = CameraKitServiceStub.shared,
    monitor: SessionMonitor = CameraKitServiceStub.shared
  ) {
    self.routing = routing
    self.player = player
    self.monitor = monitor
  }

  public var routing: Routing = RoutingStub()
  public var player: SessionPlayer = CameraKitServiceStub.shared
  public var monitor: SessionMonitor = CameraKitServiceStub.shared
}

public let sessionReducer = AnyReducer<SessionState, SessionAction, SessionEnvironment> { state, action, environment in
  switch action {
  case .onAppear:
    UIApplication.shared.isIdleTimerDisabled = true
    return .merge(
      environment.monitor.monitorErrorPublisher
        .receive(on: DispatchQueue.main)
        .compactMap { $0 }
        .map { error in SessionAction.showError(error) }
        .eraseToEffect()
        .cancellable(id: MonitorID(), cancelInFlight: true),
      .fireAndForget {
        await environment.player.play()
      }
    )
  case .onDisappear:
    UIApplication.shared.isIdleTimerDisabled = false
    environment.player.stop()
    return .cancel(id: MonitorID())
  case .showError(let error):
    environment.player.stop()
    state.localState.alertError = error
    return .cancel(id: MonitorID())
  case .tapBack:
    return .fireAndForget {
      await environment.routing.selectTab(animated: true)
    }
  case .switchCameras:
    state.localState.hasSwitchedCameras.toggle()
  case .binding(let action):
    if action.keyPath == \.$localState.alertError, state.localState.alertError == nil {
      return .fireAndForget {
        await environment.routing.selectTab(animated: true)
      }
    }
  }
  return .none
}
.binding()

private struct MonitorID: Hashable {}
