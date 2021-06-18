public enum CKQuality: Int, Codable, CaseIterable, Comparable {
  case min
  case low
  case medium
  case high
  case max

  public static func < (lhs: CKQuality, rhs: CKQuality) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}
