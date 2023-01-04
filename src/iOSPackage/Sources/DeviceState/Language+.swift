import Assets
import Foundation
import CoreGraphics
import Device

public extension Optional where Wrapped == Language {
  func resolution(_ value: Resolution) -> String {
    "\(value.width)x\(value.height)"
  }

  func fps(_ value: Int) -> String {
    "\(value)FPS"
  }

  func fov(_ value: Int) -> String {
    "\(value)°"
  }

  func zoom(_ value: Double) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.maximumFractionDigits = 2
    let value = numberFormatter.string(from: NSNumber(value: value)) ?? ""
    return value.appending("x")
  }

  func quality(_ quality: Quality) -> String {
    switch quality {
    case .min:
      return string(.qualityMin)
    case .low:
      return string(.qualityLow)
    case .medium:
      return string(.qualityMedium)
    case .high:
      return string(.qualityHigh)
    case .max:
      return string(.qualityMax)
    }
  }

  func polarPattern(_ value: PolarPattern) -> String {
    switch value {
    case .stereo:
      return string(.polarPatternStereo)
    case .subcardioid:
      return string(.polarPatternSubcardioid)
    case .default:
      return string(.polarPatternUnspecified)
    case .omnidirectional:
      return string(.polarPatternOmnidirectional)
    case .cardioid:
      return string(.polarPatternCardioid)
    }
  }

  func bitrate(_ value: Bitrate) -> String {
    let unitFormatter = MeasurementFormatter()
    unitFormatter.unitStyle = .medium
    unitFormatter.locale = locale
    let numberFormatter = NumberFormatter()
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.maximumFractionDigits = 3
    numberFormatter.locale = locale
    unitFormatter.numberFormatter = numberFormatter
    let units: [UnitInformationStorage] = [.bits, .kilobits, .megabits, .gigabits, .terabits]
    let log = value.bitsPerSecond > 0 ? Int(log10(Double(value.bitsPerSecond)) / 3) : 0
    let unitIndex = min(units.count - 1, max(0, log))
    let size = Decimal(value.bitsPerSecond) / pow(1000, unitIndex)
    let sizeDouble = NSDecimalNumber(decimal: size).doubleValue
    let bitrateString = unitFormatter.string(from: Measurement(value: sizeDouble, unit: units[unitIndex]))
    unitFormatter.unitStyle = .short
    let secondString = unitFormatter.string(from: UnitDuration.seconds)
    return "\(bitrateString)/\(secondString)"
  }
}
