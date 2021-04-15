public enum CKQuality {
  case min
  case low
  case medium
  case high
  case max

  var doubleValue: Double {
    switch self {
    case .min:
      return 0.1
    case .low:
      return 0.3
    case .medium:
      return 0.5
    case .high:
      return 0.7
    case .max:
      return 1
    }
  }
}
