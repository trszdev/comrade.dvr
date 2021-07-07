final class AKSingletonAutoRegistryAdapter: AKAutoregistryAdapter, AKSingletonAutoRegistry {
  func autoregister<T>(_ type: T.Type, value: T) {
    autoregister(type, construct: { () -> T in value })
  }
}
