public struct CKBitrate: Codable, Hashable {
  public let bitsPerSecond: Int

  public init(bitsPerSecond: Int) {
    self.bitsPerSecond = bitsPerSecond
  }
}
