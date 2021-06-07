import Foundation

extension TimeInterval {
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
