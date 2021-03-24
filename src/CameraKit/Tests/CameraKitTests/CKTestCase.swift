import XCTest
import AutocontainerKit
@testable import CameraKit

class CKTestCase: XCTestCase {
  lazy var avLocator: AKLocator = {
    let container = AKHashContainer()
    container.singleton.autoregister(AKLocator.self, value: container)
    CKAVAssembly().assemble(container: container)
    return container
  }()
}
