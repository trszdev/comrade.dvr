import Assets
import LocalizedUtils
import Util
import Foundation

public extension Optional where Wrapped == Language {
  func occupiedSpace(_ value: FileSize) -> String {
    "\(string(.usedSpace)): \(fileSize(value))"
  }

  func lastCapture(_ value: Date?) -> String {
    if let value = value {
      return "\(string(.lastCapture)): \(format(date: value, timeStyle: .medium, dateStyle: .medium))"
    }
    return "\(string(.lastCapture)): N/A"
  }

  func errorMessage(_ error: StartStateError) -> String {
    switch error {
    case .unexpectedError(let message):
      return String(format: string(.errorOccuredTemplate), message)
    case .microphoneRuntimeError:
      return string(.microphoneRuntimeError)
    case .frontCameraRuntimeError:
      return string(.frontCameraRuntimeError)
    case .backCameraRuntimeError:
      return string(.backCameraRuntimeError)
    }
  }
}
