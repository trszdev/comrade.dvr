import Foundation

public struct CKDeviceID: Hashable, Codable {
  public let value: String

  public init(value: String? = nil) {
    self.value = value ?? UUID().uuidString
  }
}
