import ComposableArchitecture
import Util

public extension ViewStore {
  func currentValuePublisher<Value>(_ keyPath: KeyPath<ViewState, Value>) -> CurrentValuePublisher<Value> {
    .init(currentValue: { self.state[keyPath: keyPath] }, publisher: publisher.map(keyPath).eraseToAnyPublisher())
  }
}
