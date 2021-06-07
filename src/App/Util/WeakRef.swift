final class WeakRef<T: AnyObject> {
  weak var value: T?

  init(_ object: T? = nil) {
    self.value = object
  }
}
