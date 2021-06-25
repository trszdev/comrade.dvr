import CameraKit

struct ForcedConfigurationPicker: CKNearestConfigurationPicker {
  let devices: [Device]

  func nearestConfiguration(for conf: CKConfiguration) -> CKConfiguration {
    devices.configuration
  }
}
