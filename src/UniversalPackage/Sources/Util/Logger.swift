import Foundation

public struct Logger {
  public enum Level: Int {
    case verbose
    case debug
    case info
    case warn
    case crit
  }

  public struct Source {
    var fileName: String
    var line: Int
    var column: Int
    var function: String
  }

  public var log: (_ message: @autoclosure () -> String, _ level: Level, _ source: Source) -> Void

  public func verbose(
    _ message: @autoclosure () -> String = "",
    fileName: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
  ) {
    log(message(), .verbose, Source(fileName: fileName, line: line, column: column, function: function))
  }

  public func debug(
    _ message: @autoclosure () -> String = "",
    fileName: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
  ) {
    log(message(), .debug, Source(fileName: fileName, line: line, column: column, function: function))
  }

  public func info(
    _ message: @autoclosure () -> String = "",
    fileName: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
  ) {
    log(message(), .info, Source(fileName: fileName, line: line, column: column, function: function))
  }

  public func warn(
    error: Error,
    fileName: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
  ) {
    log(String(describing: error), .warn, Source(fileName: fileName, line: line, column: column, function: function))
  }

  public func warn(
    _ message: @autoclosure () -> String = "",
    fileName: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
  ) {
    log(message(), .warn, Source(fileName: fileName, line: line, column: column, function: function))
  }

  public func crit(
    _ message: @autoclosure () -> String = "",
    fileName: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
  ) {
    log(message(), .crit, Source(fileName: fileName, line: line, column: column, function: function))
  }

  public func crit(
    error: Error,
    fileName: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
  ) {
    log(String(describing: error), .crit, Source(fileName: fileName, line: line, column: column, function: function))
  }

  public static var printLogger: Self {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    return Self { message, level, source in
      guard level.rawValue > Level.verbose.rawValue else { return }
      let timeStamp = formatter.string(from: Date())
      let fileName = URL(fileURLWithPath: source.fileName).deletingPathExtension().lastPathComponent
      let sourceString = "\(fileName)#\(source.function)+\(source.line):\(source.column)"
      print(">> \(level.emoji) [\(timeStamp)|\(sourceString)] \(message())")
    }
  }

  public static var nsLogger: Self {
    Self { message, level, source in
      guard level.rawValue > Level.debug.rawValue else { return }
      NSLog(
        "[%@] %@, (line: %d, column: %d, function: %@, fileName: %@)",
        level.name,
        message(),
        source.line,
        source.column,
        source.function,
        source.fileName
      )
    }
  }

  public static var bypassLogger: Self {
    Self { _, _, _ in }
  }
}

private extension Logger.Level {
  var emoji: String {
    switch self {
    case .verbose:
      return "⚪️"
    case .debug:
      return "🟢"
    case .info:
      return "🔵"
    case .warn:
      return "🟠"
    case .crit:
      return "🔴"
    }
  }

  var name: String {
    switch self {
    case .verbose:
      return "VERBOSE"
    case .debug:
      return "DEBUG"
    case .info:
      return "INFO"
    case .warn:
      return "WARNING"
    case .crit:
      return "ERROR"
    }
  }
}

public var log: Logger = .printLogger
