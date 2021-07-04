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
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm:ss"
    let timestamp = dateFormatter.string(from: Date())
    let logline = ">>> [\(timestamp)] \(value)"
    mutableLog.append(logline)
    mutableLog.append("\n")
    print(logline)
    DispatchQueue.main.async { [weak self, mutableLog] in
      self?.log = mutableLog as String
    }
  }
}
