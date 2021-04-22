import XCTest
@testable import CameraKit

final class CKAVNearestSingleCameraConfigurationPickerTests: CKNearestConfigurationPickerTests {
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
            videoQuality: .medium
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
            videoQuality: .medium
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
            videoQuality: .medium
          )
        ),
      ],
      microphone: nil
    )
  }

  override func makePicker() -> CKNearestConfigurationPicker {
    CKAVNearestSingleCameraConfigurationPicker(
      adjustableConfiguration: CKAdjustableConfiguration(cameras: [sampleCamera.id: sampleCamera], microphone: nil)
    )
  }

  override func makeEmptyPicker() -> CKNearestConfigurationPicker {
    CKAVNearestSingleCameraConfigurationPicker(adjustableConfiguration: .empty)
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
}
