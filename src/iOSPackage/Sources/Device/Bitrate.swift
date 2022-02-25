import CoreGraphics

public struct Bitrate: Codable, Hashable {
  public let bitsPerSecond: Int

  public init(bitsPerSecond: Int) {
    self.bitsPerSecond = bitsPerSecond
  }
}
