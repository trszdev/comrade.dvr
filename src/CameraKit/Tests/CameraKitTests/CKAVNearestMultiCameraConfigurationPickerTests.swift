import XCTest
@testable import CameraKit

final class CKAVNearestMultiCameraConfigurationPickerTests: CKNearestConfigurationPickerTests {
  override var isAbstractTestCase: Bool { false }

  override var nonExistingConfiguration: CKConfiguration {
    CKConfiguration(
      cameras: [
        CKDeviceID(value: "404"): CKDevice(
          id: CKDeviceID(value: "404"),
          configuration: existingConfiguration.cameras.first!.value.configuration
        ),
      ],
      microphone: nil
    )
  }

  override var existingConfiguration: CKConfiguration {
    CKConfiguration(
      cameras: [
        CKDevice(
          id: sampleCamera.id,
          configuration: CKCameraConfiguration(
            id: sampleCamera.configuration[0].id,
            size: sampleCamera.configuration[0].size,
            zoom: sampleCamera.configuration[0].minZoom,
            fps: sampleCamera.configuration[0].minFps,
            fieldOfView: sampleCamera.configuration[0].fieldOfView,
            orientation: .portrait,
            autoFocus: .phaseDetection,
            stabilizationMode: .auto,
            videoGravity: .resize,
            videoQuality: .medium,
            useH265: true,
            bitrate: 1000
          )
        ),
      ],
      microphone: nil
    )
  }

  override var requestedConfiguration: CKConfiguration {
    CKConfiguration(
      cameras: [
        CKDevice(
          id: sampleCamera.id,
          configuration: CKCameraConfiguration(
            size: sampleCamera.configuration[0].size,
            zoom: 1.5,
            fps: 60,
            fieldOfView: 70,
            orientation: .portrait,
            autoFocus: .phaseDetection,
            stabilizationMode: .auto,
            videoGravity: .resize,
            videoQuality: .medium,
            useH265: true,
            bitrate: 1000
          )
        ),
      ],
      microphone: nil
    )
  }

  override var resultConfiguration: CKConfiguration {
    CKConfiguration(
      cameras: [
        CKDevice(
          id: sampleCamera.id,
          configuration: CKCameraConfiguration(
            id: sampleCamera.configuration[0].id,
            size: sampleCamera.configuration[0].size,
            zoom: 1.5,
            fps: 30,
            fieldOfView: 80,
            orientation: .portrait,
            autoFocus: .phaseDetection,
            stabilizationMode: .auto,
            videoGravity: .resize,
            videoQuality: .medium,
            useH265: true,
            bitrate: 1000
          )
        ),
      ],
      microphone: nil
    )
  }

  override func makePicker() -> CKNearestConfigurationPicker {
    makePicker(cameras: [sampleCamera], multicamSets: [[sampleMulticamConfig]])
  }

  override func makeEmptyPicker() -> CKNearestConfigurationPicker {
    makePicker(cameras: [], multicamSets: [])
  }

  func testBiggerMulticamConfiguration() {
    let picker = makePicker(
      cameras: [sampleCamera, sampleCamera2],
      multicamSets: [[sampleMulticamConfig, sampleMulticamConfig2]]
    )
    let conf = picker.nearestConfiguration(for: existingConfiguration)
    XCTAssert(conf.cameras.isEmpty)
  }

  func testSmallerMulticamConfiguration() {
    let picker = makePicker(
      cameras: [sampleCamera, sampleCamera2],
      multicamSets: [[sampleMulticamConfig]]
    )
    let conf = picker.nearestConfiguration(for: existingConfiguration2)
    XCTAssertEqual(conf, existingConfiguration)
  }

  private func makePicker(
    cameras: Set<CKDevice<[CKAdjustableCameraConfiguration]>>,
    multicamSets: [Set<CKDevice<CKAdjustableCameraConfiguration>>]
  ) -> CKNearestConfigurationPicker {
    CKAVNearestMultiCameraConfigurationPicker(
      adjustableConfiguration: CKAdjustableConfiguration(
        cameras: Dictionary(uniqueKeysWithValues: cameras.map { ($0.id, $0) }),
        microphone: nil
      ),
      multicamSetsProvider: CKAVMulticamSetsProviderStub(
        multicamSets: multicamSets.map { Set($0.map { CKDevice(id: $0.id, configuration: [$0.configuration]) }) }
      )
    )
  }

  private var existingConfiguration2: CKConfiguration {
    CKConfiguration(
      cameras: [
        CKDevice(
          id: sampleCamera.id,
          configuration: CKCameraConfiguration(
            id: sampleCamera.configuration[0].id,
            size: sampleCamera.configuration[0].size,
            zoom: sampleCamera.configuration[0].minZoom,
            fps: sampleCamera.configuration[0].minFps,
            fieldOfView: sampleCamera.configuration[0].fieldOfView,
            orientation: .portrait,
            autoFocus: .phaseDetection,
            stabilizationMode: .auto,
            videoGravity: .resize,
            videoQuality: .medium,
            useH265: true,
            bitrate: 1000
          )
        ),
        CKDevice(
          id: sampleCamera2.id,
          configuration: CKCameraConfiguration(
            id: sampleCamera2.configuration[0].id,
            size: sampleCamera2.configuration[0].size,
            zoom: sampleCamera2.configuration[0].minZoom,
            fps: sampleCamera2.configuration[0].minFps,
            fieldOfView: sampleCamera2.configuration[0].fieldOfView,
            orientation: .portrait,
            autoFocus: .phaseDetection,
            stabilizationMode: .auto,
            videoGravity: .resize,
            videoQuality: .medium,
            useH265: true,
            bitrate: 1000
          )
        ),
      ],
      microphone: nil
    )
  }

  private var sampleCamera = CKDevice<[CKAdjustableCameraConfiguration]>(
    id: CKDeviceID(value: "id1"),
    configuration: [
      CKAdjustableCameraConfiguration(
        id: CKDeviceConfigurationID(value: "conf_id1"),
        size: CKSize(width: 100, height: 100),
        minZoom: 1,
        maxZoom: 2,
        minFps: 10,
        maxFps: 30,
        fieldOfView: 80,
        supportedStabilizationModes: [.auto, .off, .cinematic, .cinematicExtended, .standard],
        isMulticamAvailable: true
      ),
      CKAdjustableCameraConfiguration(
        id: CKDeviceConfigurationID(value: "conf_id2"),
        size: CKSize(width: 200, height: 200),
        minZoom: 1,
        maxZoom: 2,
        minFps: 10,
        maxFps: 60,
        fieldOfView: 80,
        supportedStabilizationModes: [.auto, .off, .cinematic, .cinematicExtended, .standard],
        isMulticamAvailable: true
      ),
    ]
  )

  private lazy var sampleCamera2 = CKDevice(id: CKDeviceID(value: "id2"), configuration: sampleCamera.configuration)

  private var sampleMulticamConfig: CKDevice<CKAdjustableCameraConfiguration> {
    CKDevice(id: sampleCamera.id, configuration: sampleCamera.configuration[0])
  }

  private var sampleMulticamConfig2: CKDevice<CKAdjustableCameraConfiguration> {
    CKDevice(id: sampleCamera2.id, configuration: sampleCamera2.configuration[0])
  }
}

private struct CKAVMulticamSetsProviderStub: CKAVMulticamSetsProvider {
  let multicamSets: [Set<CKDevice<[CKAdjustableCameraConfiguration]>>]
}
