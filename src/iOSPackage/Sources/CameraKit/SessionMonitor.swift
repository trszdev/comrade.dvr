import AVFoundation
import Combine
import Util

public protocol SessionMonitor {
  var monitorErrorPublisher: AnyPublisher<SessionMonitorError?, Never> { get }
  func checkAfterStart(session: Session)
}

public enum SessionMonitorError: String, Error, Identifiable {
  case systemPressureExceeded
  case hardwareCostExceeded
  case runtimeError

  public var id: String { rawValue }
}

final class SessionMonitorImpl: SessionMonitor {
  private let errorSubject = PassthroughSubject<SessionMonitorError?, Never>()
  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didReceiveRuntimeError(notification:)),
      name: .AVCaptureSessionRuntimeError,
      object: nil
    )
  }

  var monitorErrorPublisher: AnyPublisher<SessionMonitorError?, Never> { errorSubject.eraseToAnyPublisher() }

  func checkAfterStart(session: Session) {
    if let singleCameraSession = session.singleCameraSession {
      if #available(iOS 16.0, *) {
        if singleCameraSession.hardwareCost >= 1 {
          log.warn("hardwareCostExceeded")
          errorSubject.send(.hardwareCostExceeded)
        }
      }
    } else if let multiCameraSession = session.multiCameraSession {
      if multiCameraSession.hardwareCost >= 1 {
        log.warn("hardwareCostExceeded")
        errorSubject.send(.hardwareCostExceeded)
      }
      if multiCameraSession.systemPressureCost >= 1 {
        log.warn("systemPressureExceeded")
        errorSubject.send(.systemPressureExceeded)
      }
    }
  }

  @objc private func didReceiveRuntimeError(notification: Notification) {
    guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else {
      log.crit("Bad notification: \(notification)")
      return
    }
    switch error.code {
    case .sessionHardwareCostOverage:
      errorSubject.send(.hardwareCostExceeded)
    default:
      log.warn(error: error)
      log.warn("Runtime error")
      errorSubject.send(.runtimeError)
    }
  }
}
