import XCTest
import Util
import Combine

final class CurrentValuePublisherTests: XCTestCase {
  func testDeinit() {
    var subject: CurrentValueSubject<String, Never>! = .init("123")
    weak var weakRef = subject
    var publisher: CurrentValuePublisher<String>! = subject.currentValuePublisher
    XCTAssertEqual(publisher.currentValue(), "123")
    subject = nil
    XCTAssertNotNil(weakRef)
    publisher = nil
    XCTAssertNil(weakRef)
  }
}
