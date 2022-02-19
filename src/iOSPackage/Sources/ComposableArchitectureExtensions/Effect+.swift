import ComposableArchitecture
import Combine

public extension Effect {
  static func task(block: @Sendable @escaping () async -> Void) -> Self {
    Deferred {
      Future<Bool, Never> { promise in
        Task {
          await block()
          promise(.success(true))
        }
      }
    }
    .eraseToEffect()
    .fireAndForget()
  }

  static func async(block: @Sendable @escaping () async -> Output) -> Effect<Output, Never> {
    Deferred {
      Future<Output, Never> { promise in
        Task {
          let output = await block()
          promise(.success(output))
        }
      }
    }
    .eraseToEffect()
  }
}
