public extension AKSingletonAutoRegistry {
  func autoregister<T>(value: T) {
    autoregister(T.self, value: value)
  }
}
