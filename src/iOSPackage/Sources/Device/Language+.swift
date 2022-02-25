import Assets

public extension Optional where Wrapped == Language {
  func resolution(_ value: Resolution) -> String {
    "\(value.width)x\(value.height)"
  }

  func fps(_ value: Int) -> String {
    "\(value)FPS"
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
}
