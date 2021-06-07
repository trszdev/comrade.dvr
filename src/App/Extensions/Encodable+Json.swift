import Foundation

extension Encodable {
  func jsonData(encoder: JSONEncoder? = nil) throws -> Data {
    let jsonEncoder = encoder ?? JSONEncoder()
    return try jsonEncoder.encode(self)
  }
}
