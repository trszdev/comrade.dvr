public final class WeakRef<T: AnyObject> {
  public weak var value: T?

  public init(_ object: T? = nil) {
    self.value = object
  }
}
