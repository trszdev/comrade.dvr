public struct CKSize: Hashable, Codable {
  public let width: Int
  public let height: Int

  public init(width: Int, height: Int) {
    self.width = width
    self.height = height
  }

  public var scalar: Int {
    width * height
  }
}
