public class AKHashContainer: AKContainer, AKLocator {
  public init() {}
  public var asserts = true
  public lazy private(set) var singleton: AKAutoRegistry & AKSingletonAutoRegistry
    = AKSingletonAutoRegistryAdapter(registry: AKSingletonRegistry(didOutputConstructor: didOutputConstructor))
  public lazy private(set) var transient: AKAutoRegistry
    = AKAutoregistryAdapter(registry: AKTransientRegistry(didOutputConstructor: didOutputConstructor))

  public func resolve<T>(_ type: T.Type) -> T! {
    let id = ObjectIdentifier(type)
    guard let value = hash[id]?(self) else {
      assert("Constructor not found for \(type)[id: \(id)]")
      return nil
    }
    guard let result = value as? T else {
      let valueType = Swift.type(of: value)
      let valueTypeId = ObjectIdentifier(valueType.self)
      assert("Constructor outputs wrong type: \(valueType)[id: \(valueTypeId)], expected: \(type)[id: \(id)]")
      return nil
    }
    return result
  }

  private func assert(_ message: String) {
    guard asserts else { return }
    Swift.assert(false, message)
  }

  private func didOutputConstructor(id: ObjectIdentifier, constructor: @escaping (AKLocator) -> Any) {
    if hash[id] != nil {
      assert("Constructor already exists for [id: \(id)]")
    }
    hash[id] = constructor
  }

  private var hash = [ObjectIdentifier: (AKLocator) -> Any]()
}

private class AKSingletonRegistry: AKRegistry {
  let didOutputConstructor: (ObjectIdentifier, @escaping (AKLocator) -> Any) -> Void

  init(didOutputConstructor: @escaping (ObjectIdentifier, @escaping (AKLocator) -> Any) -> Void) {
    self.didOutputConstructor = didOutputConstructor
  }

  func register<T>(_ type: T.Type, construct: @escaping (AKLocator) -> T) {
    var instance: T?
    didOutputConstructor(ObjectIdentifier(type)) { locator in
      if instance == nil {
        instance = construct(locator)
      }
      return instance!
    }
  }
}

private class AKTransientRegistry: AKRegistry {
  let didOutputConstructor: (ObjectIdentifier, @escaping (AKLocator) -> Any) -> Void

  init(didOutputConstructor: @escaping (ObjectIdentifier, @escaping (AKLocator) -> Any) -> Void) {
    self.didOutputConstructor = didOutputConstructor
  }

  func register<T>(_ type: T.Type, construct: @escaping (AKLocator) -> T) {
    didOutputConstructor(ObjectIdentifier(type), construct)
  }
}
