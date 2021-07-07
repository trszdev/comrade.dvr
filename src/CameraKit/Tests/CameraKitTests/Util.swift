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

  static func wait(_ amount: TimeInterval, timeout: TimeInterval = 5.0) {
    let exp = Expectation()
    DispatchQueue.main.asyncAfter(deadline: .now() + amount) {
      exp.fulfill()
    }
    exp.wait(timeout: timeout)
  }
}

final class CallLogger<Table: Hashable> {
  init(_ type: Table.Type) {
  }

  func log(_ value: Table) {
    let key = value
    calls[key] = (calls[key] ?? 0) + 1
  }

  func `for`(_ value: Table) -> Int {
    let key = value
    return calls[key] ?? 0
  }

  var total: Int {
    calls.values.reduce(0) { acc, x in acc + x }
  }

  private var calls: [Table: Int] = [:]
}
