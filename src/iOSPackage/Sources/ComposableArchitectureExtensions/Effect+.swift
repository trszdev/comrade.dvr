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
    .receive(on: DispatchQueue.main)
    .eraseToEffect()
    .fireAndForget()
  }

  static func async(block: @Sendable @escaping () async -> Effect<Output, Never>) -> Effect<Output, Never> {
    Deferred {
      Future<Effect<Output, Never>, Never> { promise in
        Task {
          let output = await block()
          promise(.success(output))
        }
      }
    }
    .receive(on: DispatchQueue.main)
    .flatMap { $0 }
    .eraseToEffect()
  }

  init(value: Output, delay: DispatchQueue.SchedulerTimeType.Stride, scheduler: AnySchedulerOf<DispatchQueue>) {
    self.init(Just(value).setFailureType(to: Failure.self).delay(for: delay, scheduler: scheduler))
  }
}
