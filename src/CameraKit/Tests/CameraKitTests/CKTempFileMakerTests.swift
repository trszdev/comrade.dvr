import XCTest
@testable import CameraKit

final class CKTempFileMakerTests: CKTestCase {
  func testSample() {
    let tempFileMaker = avLocator.resolve(CKTempFileMaker.self)!
    let tempFile = tempFileMaker.makeTempFile()
    XCTAssertFalse(tempFile.path.isEmpty)
  }
}
