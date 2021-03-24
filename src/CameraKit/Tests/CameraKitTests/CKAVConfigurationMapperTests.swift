import XCTest
import Combine
import Foundation
import AVFoundation
@testable import CameraKit

final class CKAVConfigurationMapperTests: CKTestCase {
  func testNoDiscoveryOnCreation() {
    let mock = CKAVDiscoveryMock()
    _ = makeMapper(discovery: mock)
    XCTAssertEqual(mock.calls, 0)
  }

  func testHasSomeConfiguration() {
    let mapper = makeMapper()
    let cameras = mapper.currentConfiguration.cameras.values
    if !cameras.isEmpty {
      XCTAssert(cameras.allSatisfy { !$0.configuration.isEmpty })
    }
  }

  func makeMapper(discovery: CKAVDiscovery? = nil) -> CKAVConfigurationMapper {
    discovery.flatMap(CKAVConfigurationMapperImpl.init(discovery:)) ?? avLocator.resolve(CKAVConfigurationMapper.self)
  }
}

private final class CKAVDiscoveryMock: CKAVDiscovery {
  var calls = 0
  var microphone: AVCaptureDevice? {
    calls += 1
    return nil
  }

  var backCameras: [AVCaptureDevice] {
    calls += 1
    return []
  }

  var frontCameras: [AVCaptureDevice] {
    calls += 1
    return []
  }
}
