import XCTest
import Combine
import Foundation
@testable import CameraKit

final class CKUIAdjustableCameraConfigurationTests: CKTestCase {
  var sampleCamera = CKDevice<[CKAdjustableCameraConfiguration]>(
    id: CKDeviceID(value: "id1"),
    configuration: [
      CKAdjustableCameraConfiguration(
        id: CKDeviceConfigurationID(value: "conf_id1"),
        size: CKSize(width: 100, height: 100),
        minZoom: -1,
        maxZoom: 4,
        minFps: 0,
        maxFps: 30,
        fieldOfView: 70,
        supportedStabilizationModes: CKStabilizationMode.allCases,
        isMulticamAvailable: true
      ),
      CKAdjustableCameraConfiguration(
        id: CKDeviceConfigurationID(value: "conf_id2"),
        size: CKSize(width: 200, height: 200),
        minZoom: 1,
        maxZoom: 2,
        minFps: 1,
        maxFps: 30,
        fieldOfView: 80,
        supportedStabilizationModes: [],
        isMulticamAvailable: false
      ),
    ]
  )

  func testSample() {
    let uiConfiguration = sampleCamera.configuration.ui
    XCTAssertEqual(
      uiConfiguration.sizes,
      Set<CKSize>([CKSize(width: 100, height: 100), CKSize(width: 200, height: 200)])
    )
    XCTAssertEqual(uiConfiguration.minZoom, -1)
    XCTAssertEqual(uiConfiguration.maxZoom, 4)
    XCTAssertEqual(uiConfiguration.minFps, 0)
    XCTAssertEqual(uiConfiguration.maxFps, 30)
    XCTAssertEqual(uiConfiguration.minFieldOfView, 70)
    XCTAssertEqual(uiConfiguration.maxFieldOfView, 80)
    XCTAssertEqual(uiConfiguration.supportedStabilizationModes, Set(CKStabilizationMode.allCases))
    XCTAssertEqual(uiConfiguration.isMulticamAvailable, true)
  }
}
