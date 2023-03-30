import ComposableArchitecture
import CommonUI
import ComposableArchitectureExtensions
import UIKit

public struct SessionState: Equatable {
  public init(
    backCameraPreviewView: UIView? = nil,
    frontCameraPreviewView: UIView? = nil,
    hasSwitchedCameras: Bool = false
  ) {
    self.backCameraPreviewView = backCameraPreviewView
    self.frontCameraPreviewView = frontCameraPreviewView
    self.hasSwitchedCameras = hasSwitchedCameras
  }

  public var backCameraPreviewView: UIView?
  public var frontCameraPreviewView: UIView?
  public var hasSwitchedCameras = false

  var mainCameraPreviewView: UIView? {
    if hasTwoCameras {
      return hasSwitchedCameras ? frontCameraPreviewView : backCameraPreviewView
    } else {
      return backCameraPreviewView ?? frontCameraPreviewView
    }
  }

  var secondaryCameraPreviewView: UIView? {
    hasSwitchedCameras ? backCameraPreviewView : frontCameraPreviewView
  }

  var hasTwoCameras: Bool {
    frontCameraPreviewView != nil && frontCameraPreviewView != nil
  }
}

public enum SessionAction {
  case tapBack
  case switchCameras
}

public struct SessionEnvironment {
  public init(routing: Routing = RoutingStub()) {
    self.routing = routing
  }

  public var routing: Routing = RoutingStub()
}

public let sessionReducer = Reducer<SessionState, SessionAction, SessionEnvironment> { state, action, environment in
  switch action {
  case .tapBack:
    return .task {
      await environment.routing.selectTab(animated: true)
    }
  case .switchCameras:
    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    state.hasSwitchedCameras.toggle()
  }
  return .none
}
