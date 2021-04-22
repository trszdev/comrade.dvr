import XCTest
@testable import CameraKit

final class CKAVNearestMicrophoneConfigurationPickerTests: CKNearestConfigurationPickerTests {
  override var isAbstractTestCase: Bool { false }

  override var nonExistingConfiguration: CKConfiguration {
    CKConfiguration(
      cameras: [],
      microphone: CKDevice(
        id: CKDeviceID(value: "404_mic"),
        configuration: existingConfiguration.microphone!.configuration
      )
    )
  }

  override var existingConfiguration: CKConfiguration {
    CKConfiguration(
      cameras: [],
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
  }

  override var requestedConfiguration: CKConfiguration {
    CKConfiguration(
      cameras: [],
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
  }

  override var resultConfiguration: CKConfiguration {
    CKConfiguration(
      cameras: [],
      microphone: CKDevice(
        id: sampleMicrophone.id,
        configuration: CKMicrophoneConfiguration(
          id: sampleMicrophone.configuration[1].id,
          orientation: .landscapeLeft,
          location: sampleMicrophone.configuration[1].location,
          polarPattern: sampleMicrophone.configuration[1].polarPattern,
          duckOthers: true,
          useSpeaker: true,
          useBluetoothCompatibilityMode: true,
          audioQuality: .medium
        )
      )
    )
  }

  override func makePicker() -> CKNearestConfigurationPicker {
    CKAVNearestMicrophoneConfigurationPicker(
      adjustableConfiguration: CKAdjustableConfiguration(cameras: [:], microphone: sampleMicrophone)
    )
  }

  override func makeEmptyPicker() -> CKNearestConfigurationPicker {
    CKAVNearestMicrophoneConfigurationPicker(adjustableConfiguration: .empty)
  }

  private var sampleMicrophone = CKDevice<[CKAdjustableMicrophoneConfiguration]>(
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
}
