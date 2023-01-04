public struct Factory<Value> {
  public var make: () -> Value

  public init(make: @escaping () -> Value) {
    self.make = make
  }

  public init(_ valueFactory: @autoclosure @escaping () -> Value) {
    make = valueFactory
  }
}
