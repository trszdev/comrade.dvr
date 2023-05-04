public final class Lazy<Value> {
  public init(valueFactory: Factory<Value>) {
    self.valueFactory = valueFactory
  }

  public convenience init(_ value: @autoclosure @escaping () -> Value) {
    self.init(valueFactory: .init(make: value))
  }

  public lazy var value: Value = valueFactory.make()

  private let valueFactory: Factory<Value>
}
