public extension AKAutoRegistry {
  func autoregister<T>(construct: @escaping (()) -> T) {
    autoregister(T.self, construct: construct)
  }

  func autoregister<T, A>(construct: @escaping (A) -> T) {
    autoregister(T.self, construct: construct)
  }

  func autoregister<T, A, B>(construct: @escaping ((A, B)) -> T) {
    autoregister(T.self, construct: construct)
  }

  func autoregister<T, A, B, C>(construct: @escaping ((A, B, C)) -> T){
    autoregister(T.self, construct: construct)
  }

  func autoregister<T, A, B, C, D>(construct: @escaping ((A, B, C, D)) -> T) {
    autoregister(T.self, construct: construct)
  }

  func autoregister<T, A, B, C, D, E>(construct: @escaping ((A, B, C, D, E)) -> T) {
    autoregister(T.self, construct: construct)
  }

  func autoregister<T, A, B, C, D, E, F>(construct: @escaping ((A, B, C, D, E, F)) -> T) {
    autoregister(T.self, construct: construct)
  }

  func autoregister<T, A, B, C, D, E, F, G>(construct: @escaping ((A, B, C, D, E, F, G)) -> T) {
    autoregister(T.self, construct: construct)
  }

  func autoregister<T, A, B, C, D, E, F, G, H>(construct: @escaping ((A, B, C, D, E, F, G, H)) -> T) {
    autoregister(T.self, construct: construct)
  }
}
