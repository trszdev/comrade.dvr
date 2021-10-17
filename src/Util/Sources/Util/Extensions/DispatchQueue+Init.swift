import Foundation

public extension DispatchQueue {
  convenience init() {
    self.init(label: UUID().uuidString)
  }
}
