import Assets
import LocalizedUtils
import Util
import Foundation
import CameraKit

public extension Optional where Wrapped == Language {
  func errorMessage(_ error: SessionMonitorError) -> String {
    switch error {
    case .systemPressureExceeded:
      return string(.systemPressureExceeded)
    case .hardwareCostExceeded:
      return string(.hardwareCostExceeded)
    case .runtimeError:
      return string(.runtimeError)
    }
  }
}
