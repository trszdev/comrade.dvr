import Combine
import Foundation

final class TempSetting<Value: Codable>: Setting {
  init(value: Value) {
    self.value = value
    self.currentValueSubject = CurrentValueSubject<Value, Never>(value)
  }

  private(set) var value: Value

  var publisher: AnyPublisher<Value, Never> {
    currentValueSubject.eraseToAnyPublisher()
  }

  func update(newValue: Value) throws {
    value = newValue
    currentValueSubject.send(newValue)
  }

  private let currentValueSubject: CurrentValueSubject<Value, Never>
}
