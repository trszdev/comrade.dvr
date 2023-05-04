import XCTest
import Assets
import SwiftUI

final class ColorAssetTests: XCTestCase {
  func testUIColor() {
    XCTAssertEqual(ColorAsset.textColorDefault.uiColor(for: .light).rgb, [0, 0, 0])
    XCTAssertEqual(ColorAsset.textColorDefault.uiColor(for: .dark).rgb, [1, 1, 1])
    XCTAssert([[0, 0, 0], [1, 1, 1]].contains(ColorAsset.textColorDefault.uiColor().rgb))
  }

  func testColor() {
    XCTAssertEqual(UIColor(ColorAsset.textColorDefault.color(for: .light)).rgb, [0, 0, 0])
    XCTAssertEqual(UIColor(ColorAsset.textColorDefault.color(for: .dark)).rgb, [1, 1, 1])
    XCTAssert([[0, 0, 0], [1, 1, 1]].contains(UIColor(ColorAsset.textColorDefault.color()).rgb))
  }
}

private extension UIColor {
  var rgb: [CGFloat] {
    [
      CIColor(color: self).red,
      CIColor(color: self).green,
      CIColor(color: self).blue,
    ]
  }
}
