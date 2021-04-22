import XCTest
import Combine
import Foundation
import AVFoundation
@testable import CameraKit

final class CKAVConfigurationMapperTests: CKTestCase {
  func testNoDiscoveryOnCreation() {
    let mock = CKAVDiscoveryMock()
    _ = makeMapper(discovery: mock)
    XCTAssertEqual(mock.calls.total, 0)
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
  enum Table {
    case backCameras
    case frontCameras
    case audioInputs
    case multiCameraDeviceSets
  }

  let calls = CallLogger(Table.self)

  var backCameras: [AVCaptureDevice] {
    calls.log(.backCameras)
    return []
  }

  var frontCameras: [AVCaptureDevice] {
    calls.log(.frontCameras)
    return []
  }

  var audioInputs: [AVAudioSessionPortDescription] {
    calls.log(.audioInputs)
    return []
  }

  var multiCameraDeviceSets: [Set<AVCaptureDevice>] {
    calls.log(.multiCameraDeviceSets)
    return []
  }
}
