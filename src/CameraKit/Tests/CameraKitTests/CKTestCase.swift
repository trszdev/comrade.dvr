import XCTest
import AutocontainerKit
@testable import CameraKit

class CKTestCase: XCTestCase {
  var isAbstractTestCase: Bool { false }

  override func perform(_ run: XCTestRun) {
    guard !isAbstractTestCase else { return }
    super.perform(run)
  }

  func notImplemented() -> Never {
    fatalError("Not implemented")
  }

  lazy var avLocator: AKLocator = CKAVAssembly().hashContainer
}
