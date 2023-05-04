import Assets
import Util
import Foundation

public extension Optional where Wrapped == Language {
  func assetSize(_ fileSize: FileSize?) -> String {
    guard let fileSize = fileSize else {
      return "∞"
    }
    return self.fileSize(fileSize)
  }

  func fileSize(_ fileSize: FileSize?) -> String {
    guard let fileSize = fileSize else {
      return string(.unavailable)
    }
    let unitFormatter = MeasurementFormatter()
    unitFormatter.unitStyle = .short
    unitFormatter.locale = self?.locale
    let numberFormatter = NumberFormatter()
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.maximumFractionDigits = 3
    numberFormatter.locale = self?.locale
    unitFormatter.numberFormatter = numberFormatter
    let units: [UnitInformationStorage] = [.bytes, .kilobytes, .megabytes, .gigabytes, .terabytes]
    let log = fileSize.bytes > 0 ? Int(log2(Double(fileSize.bytes)) / 10) : 0
    let unitIndex = min(units.count - 1, max(0, log))
    let size = Decimal(fileSize.bytes) / pow(1024, unitIndex)
    let sizeDouble = NSDecimalNumber(decimal: size).doubleValue
    return unitFormatter.string(from: Measurement(value: sizeDouble, unit: units[unitIndex]))
  }
}
