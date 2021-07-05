// swiftlint:disable large_tuple
public protocol AKLocator: AnyObject {
  func resolve<T>(_ type: T.Type) -> T!
  func resolve<T>(_ type: T.Type, locator: AKLocator) -> T!
  func canResolve<T>(_ type: T.Type) -> Bool
}

public protocol AKAutoRegistry: AnyObject {
  // use (()) instead of () to disambiguate this overload from autoregister<T, A>
  func autoregister<T>(_ type: T.Type, construct: @escaping (()) -> T)
  func autoregister<T, A>(_ type: T.Type, construct: @escaping (A) -> T)
  // use ((A, B)) instead of (A, B) to disambiguate this overload from autoregister<T, A>
  func autoregister<T, A, B>(_ type: T.Type, construct: @escaping ((A, B)) -> T)
  func autoregister<T, A, B, C>(_ type: T.Type, construct: @escaping ((A, B, C)) -> T)
  func autoregister<T, A, B, C, D>(_ type: T.Type, construct: @escaping ((A, B, C, D)) -> T)
  func autoregister<T, A, B, C, D, E>(_ type: T.Type, construct: @escaping ((A, B, C, D, E)) -> T)
  func autoregister<T, A, B, C, D, E, F>(_ type: T.Type, construct: @escaping ((A, B, C, D, E, F)) -> T)
  func autoregister<T, A, B, C, D, E, F, G>(_ type: T.Type, construct: @escaping ((A, B, C, D, E, F, G)) -> T)
  func autoregister<T, A, B, C, D, E, F, G, H>(_ type: T.Type, construct: @escaping ((A, B, C, D, E, F, G, H)) -> T)
}

public protocol AKSingletonAutoRegistry: AnyObject {
  func autoregister<T>(_ type: T.Type, value: T)
}

public protocol AKContainer: AnyObject {
  var singleton: AKAutoRegistry & AKSingletonAutoRegistry { get }
  var transient: AKAutoRegistry { get }
}

public protocol AKAssembly {
  func assemble(container: AKContainer)
}

protocol AKRegistry: AnyObject {
  func register<T>(_ type: T.Type, construct: @escaping (AKLocator) -> T)
}
