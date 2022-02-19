import Foundation
import SwiftUI

public enum Language: String, CaseIterable, Equatable {
  case ru
  case en

  internal var bundle: Bundle {
    if let path = Bundle.module.path(forResource: rawValue, ofType: "lproj") {
      return Bundle(path: path) ?? .module
    }
    return .module
  }

  public var locale: Locale {
    Locale(identifier: rawValue)
  }
}

public extension Optional where Wrapped == Language {
  var calendar: Calendar {
    self?.locale.calendar ?? .current
  }

  var locale: Locale {
    self?.locale ?? .current
  }

  func format(date: Date, timeStyle: DateFormatter.Style, dateStyle: DateFormatter.Style) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = locale
    dateFormatter.timeStyle = timeStyle
    dateFormatter.dateStyle = dateStyle
    return dateFormatter.string(from: date)
  }

  func string(_ key: L10n) -> String {
    key.localized(for: self)
  }

  func duration(_ timeInterval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.calendar = calendar
    formatter.allowedUnits = [.day, .hour, .minute, .second]
    formatter.unitsStyle = .full
    return formatter.string(from: timeInterval)!
  }
}
