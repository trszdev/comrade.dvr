public enum Assert {
  public static func notImplemented() -> Never {
    fatalError("Not implemented")
  }

  public static func unexpected(_ message: String? = nil) {
    assert(false, message ?? "Unexpected")
  }
}
