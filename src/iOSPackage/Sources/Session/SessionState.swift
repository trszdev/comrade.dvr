import ComposableArchitecture
import CommonUI
import ComposableArchitectureExtensions
import UIKit
import CameraKit
import Device

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
  @BindableState public var localState = LocalState()

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
    frontCameraPreviewView != nil && frontCameraPreviewView != nil
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
  public init(routing: Routing = RoutingStub()) {
    self.routing = routing
  }

  public var routing: Routing = RoutingStub()
  public var monitor: SessionMonitor = CameraKitServiceStub.shared
}

public let sessionReducer = Reducer<SessionState, SessionAction, SessionEnvironment> { state, action, environment in
  switch action {
  case .onAppear:
    return environment.monitor.monitorErrorPublisher
      .receive(on: DispatchQueue.main)
      .compactMap { $0 }
      .map { error in SessionAction.showError(error) }
      .eraseToEffect()
      .cancellable(id: MonitorID())
  case .onDisappear:
    return .cancel(id: MonitorID())
  case .showError(let error):
    state.localState.alertError = error
  case .tapBack:
    return .task {
      await environment.routing.selectTab(animated: true)
    }
  case .switchCameras:
    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    state.localState.hasSwitchedCameras.toggle()
  case .binding:
    // check alert and stop session
    break
  }
  return .none
}
.binding()

private struct MonitorID: Hashable {}
