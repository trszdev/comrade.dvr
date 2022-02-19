import Foundation

public extension Task where Success == Never, Failure == Never {
  static func sleep(_ timeInterval: TimeInterval) async throws {
    try await Self.sleep(nanoseconds: UInt64(timeInterval.nanoseconds))
  }

  static func wait(_ timeInterval: TimeInterval) async {
    try? await Self.sleep(nanoseconds: UInt64(timeInterval.nanoseconds))
  }
}
