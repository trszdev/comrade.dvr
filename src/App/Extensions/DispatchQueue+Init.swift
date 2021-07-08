import Foundation

extension DispatchQueue {
  convenience init() {
    self.init(label: UUID().uuidString)
  }
}
