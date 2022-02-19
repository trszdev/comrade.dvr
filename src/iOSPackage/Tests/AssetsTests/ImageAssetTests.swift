import XCTest
import Assets

final class ImageAssetTests: XCTestCase {
  func testImage() {
    XCTAssertNotEqual(ImageAsset.startIconSystem.image(for: .dark), ImageAsset.startIconSystem.image(for: .light))
    XCTAssertEqual(ImageAsset.startIconSystem.image(for: .dark), ImageAsset.startIconSystem.image(for: .dark))
  }

  func testUIImage() {
    XCTAssertNotEqual(ImageAsset.startIconSystem.uiImage(for: .dark), ImageAsset.startIconSystem.uiImage(for: .light))
    XCTAssertEqual(ImageAsset.startIconSystem.uiImage(for: .dark), ImageAsset.startIconSystem.uiImage(for: .dark))
  }
}
