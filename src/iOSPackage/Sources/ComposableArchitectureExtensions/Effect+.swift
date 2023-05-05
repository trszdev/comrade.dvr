import ComposableArchitecture
import Combine
import Foundation

public extension EffectTask {
  init(value: Output, delay: DispatchQueue.SchedulerTimeType.Stride, scheduler: AnySchedulerOf<DispatchQueue>) {
    self.init(Just(value).setFailureType(to: Failure.self).delay(for: delay, scheduler: scheduler))
  }
}
