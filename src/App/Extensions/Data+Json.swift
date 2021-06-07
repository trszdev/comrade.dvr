import Foundation

extension Data {
  func decodeJson<Object: Decodable>(_ type: Object.Type, decoder: JSONDecoder? = nil) throws -> Object {
    let jsonDecoder = decoder ?? JSONDecoder()
    return try jsonDecoder.decode(type, from: self)
  }
}
