import XCTest
import AutocontainerKit
@testable import CameraKit

class CKTestCase: XCTestCase {
  var isAbstractTestCase: Bool { false }

  override func perform(_ run: XCTestRun) {
    guard !isAbstractTestCase else { return }
    super.perform(run)
  }

  lazy var avLocator: AKLocator = {
    let container = AKHashContainer()
    container.singleton.autoregister(AKLocator.self, value: container)
    CKAVAssembly().assemble(container: container)
    return container
  }()
}
