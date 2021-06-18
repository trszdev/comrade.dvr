struct CKAVNearestConfigurationPicker: CKNearestConfigurationPicker {
  struct Builder {
    let multiCameraPickerBuilder: CKAVNearestMultiCameraConfigurationPicker.Builder

    func makePicker(adjustableConfiguration: CKAdjustableConfiguration) -> CKNearestConfigurationPicker {
      CKAVNearestConfigurationPicker(
        microphonePicker: CKAVNearestMicrophoneConfigurationPicker(adjustableConfiguration: adjustableConfiguration),
        singleCameraPicker: CKAVNearestSingleCameraConfigurationPicker(
          adjustableConfiguration: adjustableConfiguration
        ),
        multiCameraPicker: multiCameraPickerBuilder.makePicker(adjustableConfiguration: adjustableConfiguration)
      )
    }

    func identityPicker() -> CKNearestConfigurationPicker {
      CKIdentityConfigurationPicker()
    }
  }

  let microphonePicker: CKNearestConfigurationPicker
  let singleCameraPicker: CKNearestConfigurationPicker
  let multiCameraPicker: CKNearestConfigurationPicker

  func nearestConfiguration(for configuration: CKConfiguration) -> CKConfiguration {
    var conf = configuration
    if configuration.cameras.count < 2 {
      conf = singleCameraPicker.nearestConfiguration(for: conf)
    } else {
      conf = multiCameraPicker.nearestConfiguration(for: conf)
    }
    conf = microphonePicker.nearestConfiguration(for: conf)
    return conf
  }
}

private struct CKIdentityConfigurationPicker: CKNearestConfigurationPicker {
  func nearestConfiguration(for configuration: CKConfiguration) -> CKConfiguration {
    configuration
  }
}
