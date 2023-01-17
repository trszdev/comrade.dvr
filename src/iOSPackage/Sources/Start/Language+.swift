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
}
