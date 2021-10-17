import Combine

public extension Result {
  static var success: Result<Void, Failure> {
    .success(())
  }
}
