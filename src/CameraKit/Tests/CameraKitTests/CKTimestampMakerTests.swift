import XCTest
@testable import CameraKit

final class CKTimestampMakerTests: CKTestCase {
  func testNearlyMonotonic() {
    let timestampMaker = avLocator.resolve(CKTimestampMakerBuilder.self).makeTimestampMaker()
    var timestamps = [CKTimestamp]()
    timestamps.append(timestampMaker.currentTimestamp)
    timestamps.append(timestampMaker.currentTimestamp)
    Expectation.wait(0.1)
    timestamps.append(timestampMaker.currentTimestamp)
    XCTAssertEqual(timestamps, timestamps.sorted())
  }

  func testFirstTimestampNearZero() {
    let timestampMaker = avLocator.resolve(CKTimestampMakerBuilder.self).makeTimestampMaker()
    let timestamp = timestampMaker.currentTimestamp
    let nanosecondsInMs = UInt64(1e6)
    XCTAssert(timestamp.nanoseconds < nanosecondsInMs / 2)
  }
}
