import Combine

protocol Setting {
  associatedtype Value: SettingValue
  var value: Value { get }
  var publisher: AnyPublisher<Value, Never> { get }
  func update(newValue: Value) throws
}
