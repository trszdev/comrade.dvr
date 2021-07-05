public class AKHashContainer: AKContainer, AKLocator {
  public init() {}
  public var asserts = true

  public lazy private(set) var singleton: AKAutoRegistry & AKSingletonAutoRegistry = {
    let registry = AKSingletonRegistry()
    registry.container = self
    return AKSingletonAutoRegistryAdapter(registry: registry)
  }()

  public lazy private(set) var transient: AKAutoRegistry = {
    let registry = AKTransientRegistry()
    registry.container = self
    return AKAutoregistryAdapter(registry: registry)
  }()

  public func resolve<T>(_ type: T.Type, locator: AKLocator) -> T! {
    let id = ObjectIdentifier(type)
    guard let value = hash[id]?(locator) else {
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

  public func canResolve<T>(_ type: T.Type) -> Bool {
    hash.keys.contains(ObjectIdentifier(type))
  }

  fileprivate func didOutputConstructor(id: ObjectIdentifier, constructor: @escaping (AKLocator) -> Any) {
    if hash[id] != nil {
      assert("Constructor already exists for [id: \(id)]")
    }
    hash[id] = constructor
  }

  private func assert(_ message: String) {
    guard asserts else { return }
    Swift.assert(false, message)
  }

  private var hash = [ObjectIdentifier: (AKLocator) -> Any]()
}

private class AKSingletonRegistry: AKRegistry {
  weak var container: AKHashContainer?

  func register<T>(_ type: T.Type, construct: @escaping (AKLocator) -> T) {
    var instance: T?
    container?.didOutputConstructor(id: ObjectIdentifier(type)) { locator in
      if instance == nil {
        instance = construct(locator)
      }
      return instance!
    }
  }
}

private class AKTransientRegistry: AKRegistry {
  weak var container: AKHashContainer?

  func register<T>(_ type: T.Type, construct: @escaping (AKLocator) -> T) {
    container?.didOutputConstructor(id: ObjectIdentifier(type), constructor: construct)
  }
}
