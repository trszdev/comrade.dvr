import CommonUI
import XCTest

final class CGExtensionsTests: XCTestCase {
  func testEmpty() {
    XCTAssertNotNil(CIImage.transparentPixel())
    XCTAssertNotNil(CGImage.transparentPixel())
  }
}
