import Combine

public extension Set where Element == AnyCancellable {
  func cancel() {
    for cancellable in self {
      cancellable.cancel()
    }
  }
}
