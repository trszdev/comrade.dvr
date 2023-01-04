import CoreGraphics

public struct Bitrate: Codable, Hashable {
  public var bitsPerSecond: Int

  public init(bitsPerSecond: Int) {
    self.bitsPerSecond = bitsPerSecond
  }
}
