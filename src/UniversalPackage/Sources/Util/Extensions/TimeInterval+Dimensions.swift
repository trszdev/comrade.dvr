import Foundation

public extension TimeInterval {
  static func nanoseconds(_ nanoseconds: Double) -> TimeInterval {
    TimeInterval(nanoseconds * 1e-9)
  }

  static func milliseconds(_ milliseconds: Double) -> TimeInterval {
    TimeInterval(milliseconds * 1000)
  }

  static func seconds(_ seconds: Double) -> TimeInterval {
    TimeInterval(seconds)
  }

  static func minutes(_ minutes: Double) -> TimeInterval {
    self.init(minutes * 60)
  }

  static func hours(_ hours: Double) -> TimeInterval {
    self.init(hours * 3600)
  }

  static func days(_ days: Double) -> TimeInterval {
    self.init(days * 24 * 3600)
  }

  var nanoseconds: Double {
    self * 1e+9
  }

  var milliseconds: Double {
    self * 1000
  }

  var seconds: Double {
    self
  }

  var minutes: Double {
    self / 60
  }

  var hours: Double {
    self / 3600
  }

  var days: Double {
    self / (24 * 3600)
  }
}
