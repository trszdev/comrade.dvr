public struct CKTimestamp: Hashable, Comparable {
  public let nanoseconds: UInt64

  public static func < (lhs: CKTimestamp, rhs: CKTimestamp) -> Bool {
    lhs.nanoseconds < rhs.nanoseconds
  }
}
