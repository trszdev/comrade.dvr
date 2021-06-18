import XCTest
import Combine
import Foundation
@testable import CameraKit

final class CKAVManagerTests: CKManagerTests {
  override var isAbstractTestCase: Bool { false }

  override func makeManager() -> CKManager {
    avLocator.resolve(CKManagerBuilder.self).makeManager(infoPlistBundle: nil, shouldPickNearest: true)
  }

  override func makeManager(mock: CKPermissionManager) -> CKManager {
    avLocator.resolve(CKAVManager.Builder.self).makeManager(mock: mock)
  }
}
