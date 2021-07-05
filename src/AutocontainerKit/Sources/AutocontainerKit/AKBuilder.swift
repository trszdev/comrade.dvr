open class AKBuilder: AKLocator {
  public weak var locator: AKLocator?

  public init(locator: AKLocator) {
    self.locator = locator
  }

  public func resolve<T>(_ type: T.Type) -> T! {
    locator?.resolve(type)
  }

  public func canResolve<T>(_ type: T.Type) -> Bool {
    locator?.canResolve(type) ?? false
  }
}
