import Combine
import Foundation

final class UserDefaultsSetting<Value: Codable>: Setting {
  init(key: String, userDefaults: UserDefaults, value: Value) {
    self.key = key
    self.userDefaults = userDefaults
    self.value = value
    self.currentValueSubject = CurrentValueSubject<Value, Never>(value)
  }

  private(set) var value: Value

  var publisher: AnyPublisher<Value, Never> {
    currentValueSubject.eraseToAnyPublisher()
  }

  func update(newValue: Value) throws {
    let options = try value.jsonData()
    value = newValue
    userDefaults.set(options, forKey: key)
    currentValueSubject.send(newValue)
  }

  private let currentValueSubject: CurrentValueSubject<Value, Never>
  private let key: String
  private let userDefaults: UserDefaults
}
