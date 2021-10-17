import Foundation

public struct FileSize: CustomStringConvertible, Codable, Hashable, Comparable {
  public let bytes: Int

  public init(bytes: Int) {
    self.bytes = bytes
  }

  public var description: String {
    let bcf = ByteCountFormatter()
    bcf.countStyle = .binary
    bcf.allowedUnits = .useAll
    bcf.includesUnit = true
    bcf.allowsNonnumericFormatting = false
    return bcf.string(fromByteCount: Int64(bytes))
  }

  public static func < (lhs: FileSize, rhs: FileSize) -> Bool {
    lhs.bytes < rhs.bytes
  }
}
