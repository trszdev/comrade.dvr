open class AKBuilder: AKLocator {
  public weak var locator: AKLocator?

  public init(locator: AKLocator) {
    self.locator = locator
  }

  public func resolve<T>(_ type: T.Type) -> T! {
    locator?.resolve(type)
  }
}
