import Foundation

public extension DateFormatter {
  static var dayInYearWithHourMinuteSecond: Self {
    let formatter = Self()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "d-MMM-yyyy_HH-mm-ss"
    return formatter
  }
}
