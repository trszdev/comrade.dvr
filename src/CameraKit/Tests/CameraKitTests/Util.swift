import XCTest

struct Expectation {
  let expectation: XCTestExpectation
  init(_ description: String? = nil, fulfillmentCount: Int = 1) {
    expectation = description.flatMap(XCTestExpectation.init(description:)) ?? XCTestExpectation()
    expectation.expectedFulfillmentCount = fulfillmentCount
    expectation.assertForOverFulfill = true
  }

  func fulfill() {
    expectation.fulfill()
  }

  func wait(timeout: TimeInterval = 5.0) {
    if case .completed = XCTWaiter().wait(for: [expectation], timeout: timeout) {
    } else {
      XCTFail("timeout exceeded")
    }
  }
}
