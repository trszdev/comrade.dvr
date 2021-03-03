// swiftlint:disable large_tuple
class AKAutoregistryAdapter: AKAutoRegistry {
  let registry: AKRegistry

  init(registry: AKRegistry) {
    self.registry = registry
  }

  func autoregister<T>(_ type: T.Type, construct: @escaping (()) -> T) {
    registry.register(type) { _ in construct(()) }
  }

  func autoregister<T, A>(_ type: T.Type, construct: @escaping (A) -> T) {
    registry.register(type) { construct($0.resolve(A.self)) }
  }

  func autoregister<T, A, B>(_ type: T.Type, construct: @escaping ((A, B)) -> T) {
    registry.register(type) {
      construct(($0.resolve(A.self), $0.resolve(B.self)))
    }
  }

  func autoregister<T, A, B, C>(_ type: T.Type, construct: @escaping ((A, B, C)) -> T) {
    registry.register(type) {
      construct(($0.resolve(A.self), $0.resolve(B.self), $0.resolve(C.self)))
    }
  }

  func autoregister<T, A, B, C, D>(_ type: T.Type, construct: @escaping ((A, B, C, D)) -> T) {
    registry.register(type) {
      construct(($0.resolve(A.self), $0.resolve(B.self), $0.resolve(C.self), $0.resolve(D.self)))
    }
  }

  func autoregister<T, A, B, C, D, E>(_ type: T.Type, construct: @escaping ((A, B, C, D, E)) -> T) {
    registry.register(type) {
      construct(($0.resolve(A.self), $0.resolve(B.self), $0.resolve(C.self), $0.resolve(D.self), $0.resolve(E.self)))
    }
  }

  func autoregister<T, A, B, C, D, E, F>(_ type: T.Type, construct: @escaping ((A, B, C, D, E, F)) -> T) {
    registry.register(type) {
      construct((
        $0.resolve(A.self),
        $0.resolve(B.self),
        $0.resolve(C.self),
        $0.resolve(D.self),
        $0.resolve(E.self),
        $0.resolve(F.self)
      ))
    }
  }

  func autoregister<T, A, B, C, D, E, F, G>(_ type: T.Type, construct: @escaping ((A, B, C, D, E, F, G)) -> T) {
    registry.register(type) {
      construct((
        $0.resolve(A.self),
        $0.resolve(B.self),
        $0.resolve(C.self),
        $0.resolve(D.self),
        $0.resolve(E.self),
        $0.resolve(F.self),
        $0.resolve(G.self)
      ))
    }
  }

  func autoregister<T, A, B, C, D, E, F, G, H>(_ type: T.Type, construct: @escaping ((A, B, C, D, E, F, G, H)) -> T) {
    registry.register(type) {
      construct((
        $0.resolve(A.self),
        $0.resolve(B.self),
        $0.resolve(C.self),
        $0.resolve(D.self),
        $0.resolve(E.self),
        $0.resolve(F.self),
        $0.resolve(G.self),
        $0.resolve(H.self)
      ))
    }
  }
}
