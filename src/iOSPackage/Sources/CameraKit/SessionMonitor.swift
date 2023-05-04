import AVFoundation
import Combine
import Util

public protocol SessionMonitor {
  var monitorErrorPublisher: CurrentValuePublisher<SessionMonitorError?> { get }
  func checkAfterStart(session: Session)
}

public enum SessionMonitorError: String, Error, Identifiable {
  case systemPressureExceeded
  case hardwareCostExceeded
  case runtimeError

  public var id: String { rawValue }
}

final class SessionMonitorImpl: SessionMonitor {
  private let errorSubject = CurrentValueSubject<SessionMonitorError?, Never>(nil)
  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didReceiveRuntimeError(notification:)),
      name: .AVCaptureSessionRuntimeError,
      object: nil
    )
  }

  var monitorErrorPublisher: CurrentValuePublisher<SessionMonitorError?> { errorSubject.currentValuePublisher }

  func checkAfterStart(session: Session) {
    errorSubject.value = nil
    if let singleCameraSession = session.singleCameraSession {
      if #available(iOS 16.0, *) {
        if singleCameraSession.hardwareCost >= 1 {
          errorSubject.value = .hardwareCostExceeded
        }
      }
    } else if let multiCameraSession = session.multiCameraSession {
      if multiCameraSession.hardwareCost >= 1 {
        errorSubject.value = .hardwareCostExceeded
      }
      if multiCameraSession.systemPressureCost >= 1 {
        errorSubject.value = .systemPressureExceeded
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
      errorSubject.value = .hardwareCostExceeded
    default:
      log.crit(error: error)
      log.crit("Runtime error")
      errorSubject.value = .runtimeError
    }
  }
}
