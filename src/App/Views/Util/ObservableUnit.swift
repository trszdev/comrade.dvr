import SwiftUI

final class ObservableValue<Value>: ObservableObject {
  @Published var value: Value

  init(_ value: Value) {
    self.value = value
  }

  func update() {
    objectWillChange.send()
  }
}

typealias ObservableUnit = ObservableValue<Void>

extension ObservableUnit {
  convenience init() {
    self.init(())
  }
}
