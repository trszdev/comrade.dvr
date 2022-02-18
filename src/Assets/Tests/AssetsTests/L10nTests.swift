import XCTest
import Assets

final class L10nTests: XCTestCase {
  func testSample() {
    XCTAssertEqual(L10n.unavailable.localized(for: .en), "Unavailable")
    XCTAssertEqual(L10n.unavailable.localized(for: .ru), "Недоступно")
    XCTAssert(["Unavailable", "Недоступно"].contains(L10n.unavailable.localized()))
  }
}
