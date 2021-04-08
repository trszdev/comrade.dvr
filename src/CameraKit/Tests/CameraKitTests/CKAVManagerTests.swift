import XCTest
import Combine
import Foundation
@testable import CameraKit

final class CKAVManagerTests: CKManagerTests {
  override var isAbstractTestCase: Bool { false }

  override func makeManager() -> CKManager {
    avLocator.resolve(CKAVManager.Builder.self).makeManager(infoPlistBundle: nil)
  }

  override func makeManager(mock: CKPermissionManager) -> CKManager {
    CKAVManager(permissionManager: mock, locator: avLocator)
  }
}
