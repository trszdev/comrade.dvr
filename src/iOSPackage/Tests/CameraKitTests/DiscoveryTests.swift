import XCTest
import AVFoundation
@testable import CameraKit

final class DiscoveryTests: XCTestCase {
  func testHasBuiltInMic() {
    XCTAssertNotNil(Discovery().builtInMic)
  }

  func testBackCamerasNotEmpty() {
    XCTExpectFailure("May be not available on simulator")
    XCTAssertFalse(Discovery().backCameras.isEmpty)
  }

  func testFrontCamerasNotEmpty() {
    XCTExpectFailure("May be not available on simulator")
    XCTAssertFalse(Discovery().frontCameras.isEmpty)
  }

  func testMultiCameraDeviceSetsNotEmpty() {
    XCTExpectFailure("May be not available on simulator")
    XCTAssertFalse(Discovery().multiCameraDeviceSets.isEmpty)
  }
}
