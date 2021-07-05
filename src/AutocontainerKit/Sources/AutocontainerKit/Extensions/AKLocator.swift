public extension AKLocator {
  func resolve<T>(_ type: T.Type) -> T! {
    resolve(type, locator: self)
  }

  func resolve<T>(_ type: T.Type, locator: AKLocator) -> T! {
    locator.resolve(type)
  }
}
