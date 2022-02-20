import XCTest
import Assets

final class ImageAssetTests: XCTestCase {
  func testImage() {
    XCTAssertNotEqual(ImageAsset.startIcon.image(for: .dark), ImageAsset.startIcon.image(for: .light))
    XCTAssertEqual(ImageAsset.startIcon.image(for: .dark), ImageAsset.startIcon.image(for: .dark))
  }

  func testUIImage() {
    XCTAssertNotEqual(ImageAsset.startIcon.uiImage(for: .dark), ImageAsset.startIcon.uiImage(for: .light))
    XCTAssertEqual(ImageAsset.startIcon.uiImage(for: .dark), ImageAsset.startIcon.uiImage(for: .dark))
  }
}
