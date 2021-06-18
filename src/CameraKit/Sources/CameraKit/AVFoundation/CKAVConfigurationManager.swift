struct CKAVConfigurationManager: CKConfigurationManager {
  struct Builder {
    let configurationMapper: CKAVConfigurationMapper
    let configurationPickerBuilder: CKAVNearestConfigurationPicker.Builder

    func makeManager(shouldPickNearest: Bool) -> CKConfigurationManager {
      CKAVConfigurationManager(
        configurationMapper: configurationMapper,
        configurationPickerBuilder: configurationPickerBuilder,
        shouldPickNearest: shouldPickNearest
      )
    }
  }

  var configurationPicker: CKNearestConfigurationPicker {
    shouldPickNearest ?
      configurationPickerBuilder.makePicker(adjustableConfiguration: adjustableConfiguration) :
      configurationPickerBuilder.identityPicker()
  }

  var adjustableConfiguration: CKAdjustableConfiguration {
    configurationMapper.currentConfiguration
  }
  
  let configurationMapper: CKAVConfigurationMapper
  let configurationPickerBuilder: CKAVNearestConfigurationPicker.Builder
  let shouldPickNearest: Bool
}
