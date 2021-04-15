import Combine
import Foundation

protocol Logger {
  func log(_ value: String)
}

protocol LogViewModel: Logger, ObservableObject {
  var log: String { get }
  var logPublished: Published<String> { get }
  var logPublisher: Published<String>.Publisher { get }
}

final class LogViewModelImpl: LogViewModel {
  var logPublisher: Published<String>.Publisher { $log }
  @Published var log: String = ""
  var logPublished: Published<String> { _log }
  private var mutableLog: NSMutableString = ""

  func log(_ value: String) {
    mutableLog.append(">>> ")
    mutableLog.append(value)
    mutableLog.append("\n")
    log = mutableLog as String
  }
}
