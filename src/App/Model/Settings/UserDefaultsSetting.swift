import Combine
import Foundation

final class UserDefaultsSetting<Value: SettingValue>: Setting {
  init(key: String, userDefaults: UserDefaults, value: Value) {
    self.key = key
    self.userDefaults = userDefaults
    self.value = userDefaults.object(Value.self, key: key) ?? value
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

private extension UserDefaults {
  func object<Value: SettingValue>(_ type: Value.Type, key: String) -> Value? {
    guard let object = data(forKey: key) else { return nil }
    return try? object.decodeJson(type)
  }
}
