import AVFoundation
import Combine
import Util

public protocol SessionMonitor {
  var errorPublisher: AnyPublisher<SessionMonitorError?, Never> { get }
  func checkAfterStart(session: Session)
}

public enum SessionMonitorError: Error {
  case systemPressureExceeded
  case hardwareCostExceeded
  case runtimeError
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

  var errorPublisher: AnyPublisher<SessionMonitorError?, Never> { errorSubject.eraseToAnyPublisher() }

  func checkAfterStart(session: Session) {
    guard let multicamSession = session.multiCameraSession else { return }

    if multicamSession.hardwareCost >= 1 {
      errorSubject.value = .hardwareCostExceeded
    }
    if multicamSession.systemPressureCost >= 1 {
      errorSubject.value = .systemPressureExceeded
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
