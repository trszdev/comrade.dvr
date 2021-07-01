import Combine

extension Result {
  static var success: Result<Void, Failure> {
    .success(())
  }
}
