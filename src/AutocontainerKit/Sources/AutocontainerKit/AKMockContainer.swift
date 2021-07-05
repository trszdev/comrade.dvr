public class AKMockContainer: AKContainer & AKLocator {
  public convenience init() {
    self.init(innerContainer: AKHashContainer(), mockContainer: AKHashContainer())
  }

  public init(innerContainer: AKContainer & AKLocator, mockContainer: AKContainer & AKLocator) {
    self.innerContainer = innerContainer
    self.mockContainer = mockContainer
  }

  public func resolve<T>(_ type: T.Type) -> T! {
    if mockContainer.canResolve(type) {
      return mockContainer.resolve(type, locator: self)
    }
    return innerContainer.resolve(type, locator: self)
  }

  public func canResolve<T>(_ type: T.Type) -> Bool {
    mockContainer.canResolve(type) || innerContainer.canResolve(type)
  }

  public let innerContainer: AKContainer & AKLocator
  public let mockContainer: AKContainer & AKLocator

  public var singleton: AKAutoRegistry & AKSingletonAutoRegistry {
    mockContainer.singleton
  }

  public var transient: AKAutoRegistry {
    mockContainer.transient
  }
}
