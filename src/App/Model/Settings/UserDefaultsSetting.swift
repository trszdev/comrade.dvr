import Combine
import Foundation

final class UserDefaultsSetting<Value: SettingValue>: Setting {
  init(key: String, userDefaults: UserDefaults, value: Value) {
    self.key = key
    self.userDefaults = userDefaults
    let storedValueOrDefault = userDefaults.object(Value.self, key: key) ?? value
    self.currentValueSubject = CurrentValueSubject<Value, Never>(storedValueOrDefault)
  }

  var value: Value {
    currentValueSubject.value
  }

  var publisher: AnyPublisher<Value, Never> {
    currentValueSubject.eraseToAnyPublisher()
  }

  func update(newValue: Value) throws {
    let encoded = try newValue.jsonData()
    userDefaults.set(encoded, forKey: key)
    currentValueSubject.send(newValue)
  }

  private let currentValueSubject: CurrentValueSubject<Value, Never>
  private let key: String
  private let userDefaults: UserDefaults
}

private extension UserDefaults {
  func object<Value: SettingValue>(_ type: Value.Type, key: String) -> Value? {
    guard let data = data(forKey: key) else { return nil }
    return try? data.decodeJson(type)
  }
}
