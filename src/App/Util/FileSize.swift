import Foundation

struct FileSize: CustomStringConvertible, Codable, Hashable {
  let bytes: Int

  var description: String {
    let bcf = ByteCountFormatter()
    bcf.countStyle = .binary
    bcf.allowedUnits = .useAll
    bcf.includesUnit = true
    bcf.allowsNonnumericFormatting = false
    return bcf.string(fromByteCount: Int64(bytes))
  }
}
