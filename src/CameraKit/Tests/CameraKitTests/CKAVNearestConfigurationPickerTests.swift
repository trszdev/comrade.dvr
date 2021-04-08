import XCTest
@testable import CameraKit

final class CKNearestConfigurationPickerTests: XCTestCase {
  var sampleCamera = CKDevice<[CKAdjustableCameraConfiguration]>(
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

  var sampleMicrophone = CKDevice<[CKAdjustableMicrophoneConfiguration]>(
    id: CKDeviceID(value: "id2"),
    configuration: [
      CKAdjustableMicrophoneConfiguration(
        id: CKDeviceConfigurationID(value: "conf_id1"),
        location: .unspecified,
        polarPattern: .unspecified
      ),
      CKAdjustableMicrophoneConfiguration(
        id: CKDeviceConfigurationID(value: "conf_id2"),
        location: .back,
        polarPattern: .stereo
      ),
    ]
  )

  lazy var existingConfiguration = CKConfiguration(
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
          videoGravity: .resize
        )
      ),
    ],
    microphone: CKDevice(
      id: sampleMicrophone.id,
      configuration: CKMicrophoneConfiguration(
        id: sampleMicrophone.configuration[0].id,
        orientation: .portrait,
        location: sampleMicrophone.configuration[0].location,
        polarPattern: sampleMicrophone.configuration[0].polarPattern,
        duckOthers: true,
        useSpeaker: true,
        useBluetoothCompatibilityMode: true,
        audioQuality: .medium
      )
    )
  )

  lazy var requestedConfiguration = CKConfiguration(
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
          videoGravity: .resize
        )
      ),
    ],
    microphone: CKDevice(
      id: sampleMicrophone.id,
      configuration: CKMicrophoneConfiguration(
        orientation: .landscapeLeft,
        location: sampleMicrophone.configuration[0].location,
        polarPattern: .omnidirectional,
        duckOthers: true,
        useSpeaker: true,
        useBluetoothCompatibilityMode: true,
        audioQuality: .medium
      )
    )
  )

  lazy var resultConfiguration = CKConfiguration(
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
          videoGravity: .resize
        )
      ),
    ],
    microphone: CKDevice(
      id: sampleMicrophone.id,
      configuration: CKMicrophoneConfiguration(
        id: sampleMicrophone.configuration[0].id,
        orientation: .landscapeLeft,
        location: sampleMicrophone.configuration[0].location,
        polarPattern: sampleMicrophone.configuration[0].polarPattern,
        duckOthers: true,
        useSpeaker: true,
        useBluetoothCompatibilityMode: true,
        audioQuality: .medium
      )
    )
  )

  lazy var nonExistingCamera = CKConfiguration(
    cameras: [
      CKDeviceID(value: "404"): CKDevice(
        id: CKDeviceID(value: "404"),
        configuration: existingConfiguration.cameras.first!.value.configuration
      ),
    ],
    microphone: CKDevice(
      id: CKDeviceID(value: "404_mic"),
      configuration: existingConfiguration.microphone!.configuration
    )
  )

  func testPickExistingConfiguration() {
    let picker = makePicker(
      adjustableConfiguration: CKAdjustableConfiguration(
        cameras: [sampleCamera.id: sampleCamera],
        microphone: sampleMicrophone
      )
    )
    let nearest = picker.nearestConfiguration(for: existingConfiguration)
    XCTAssertEqual(nearest, existingConfiguration)
  }

  func testPickNonExistingCamera() {
    let picker = makePicker(
      adjustableConfiguration: CKAdjustableConfiguration(
        cameras: [sampleCamera.id: sampleCamera],
        microphone: sampleMicrophone
      )
    )
    let nearest = picker.nearestConfiguration(for: nonExistingCamera)
    XCTAssertEqual(nearest, CKConfiguration(cameras: [:], microphone: nil))
  }

  func testPickNoCamera() {
    let picker = makePicker(
      adjustableConfiguration: CKAdjustableConfiguration(
        cameras: [:],
        microphone: sampleMicrophone
      )
    )
    let nearest = picker.nearestConfiguration(for: existingConfiguration)
    XCTAssertEqual(nearest, existingConfiguration.with(cameras: [:]))
  }

  func testPickNoMicrophone() {
    let picker = makePicker(
      adjustableConfiguration: CKAdjustableConfiguration(
        cameras: [sampleCamera.id: sampleCamera],
        microphone: nil
      )
    )
    let nearest = picker.nearestConfiguration(for: existingConfiguration)
    XCTAssertEqual(nearest, existingConfiguration.with(microphone: nil))
  }

  func testPickNearest() {
    let picker = makePicker(
      adjustableConfiguration: CKAdjustableConfiguration(
        cameras: [sampleCamera.id: sampleCamera],
        microphone: sampleMicrophone
      )
    )
    let nearest = picker.nearestConfiguration(for: requestedConfiguration)
    XCTAssertEqual(nearest, resultConfiguration)
  }

  private func makePicker(adjustableConfiguration: CKAdjustableConfiguration) -> CKNearestConfigurationPicker {
    CKAVNearestConfigurationPicker(adjustableConfiguration: adjustableConfiguration)
  }
}
