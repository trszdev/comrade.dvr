public struct CKTimestamp: Hashable, Comparable {
  public let nanoseconds: UInt64

  public init(nanoseconds: UInt64) {
    self.nanoseconds = nanoseconds
  }

  public static func < (lhs: CKTimestamp, rhs: CKTimestamp) -> Bool {
    lhs.nanoseconds < rhs.nanoseconds
  }
}
