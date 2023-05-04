import Combine

public struct CurrentValuePublisher<Value> {
  public let currentValue: () -> Value
  public let publisher: AnyPublisher<Value, Never>
  public var value: Value { currentValue() }

  public init(currentValue: @escaping () -> Value, publisher: AnyPublisher<Value, Never>) {
    self.currentValue = currentValue
    self.publisher = publisher
  }
}

extension CurrentValuePublisher: Publisher {
  public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Value == S.Input {
    publisher.receive(subscriber: subscriber)
  }

  public typealias Output = Value
  public typealias Failure = Never
}

public extension CurrentValueSubject where Failure == Never {
  var currentValuePublisher: CurrentValuePublisher<Output> {
    .init(currentValue: { self.value }, publisher: eraseToAnyPublisher())
  }
}
