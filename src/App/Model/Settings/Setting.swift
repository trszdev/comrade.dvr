import Combine

protocol Setting {
  associatedtype Value
  var value: Value { get }
  var publisher: AnyPublisher<Value, Never> { get }
  func update(newValue: Value) throws
}
