import Foundation

struct FileSize: CustomStringConvertible, Codable, Hashable, Comparable {
  let bytes: Int

  var description: String {
    let bcf = ByteCountFormatter()
    bcf.countStyle = .binary
    bcf.allowedUnits = .useAll
    bcf.includesUnit = true
    bcf.allowsNonnumericFormatting = false
    return bcf.string(fromByteCount: Int64(bytes))
  }

  static func < (lhs: FileSize, rhs: FileSize) -> Bool {
    lhs.bytes < rhs.bytes
  }
}
