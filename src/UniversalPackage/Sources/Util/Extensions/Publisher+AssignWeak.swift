import Combine

public extension Publisher where Self.Failure == Never {
  func assignWeak<Root: AnyObject>(
    to keyPath: ReferenceWritableKeyPath<Root, Self.Output>,
    on object: Root
  ) -> AnyCancellable {
    sink { [weak object] (value) in
      object?[keyPath: keyPath] = value
    }
  }
}
