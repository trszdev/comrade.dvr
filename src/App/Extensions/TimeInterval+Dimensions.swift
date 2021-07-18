import Foundation

extension TimeInterval {
  static func from(nanoseconds: Double) -> TimeInterval {
    TimeInterval(nanoseconds * 1e-9)
  }

  static func from(seconds: Double) -> TimeInterval {
    TimeInterval(seconds)
  }

  static func from(minutes: Double) -> TimeInterval {
    self.init(minutes * 60)
  }

  static func from(hours: Double) -> TimeInterval {
    self.init(hours * 3600)
  }

  static func from(days: Double) -> TimeInterval {
    self.init(days * 24 * 3600)
  }

  var nanoseconds: Double {
    self * 1e+9
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
