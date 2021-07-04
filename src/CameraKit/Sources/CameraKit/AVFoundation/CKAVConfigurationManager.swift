import AutocontainerKit

struct CKAVConfigurationManager: CKConfigurationManager {
  class Builder: AKBuilder {
    func makeManager(shouldPickNearest: Bool) -> CKConfigurationManager {
      CKAVConfigurationManager(
        configurationMapper: resolve(CKAVConfigurationMapper.self),
        configurationPickerBuilder: resolve(CKAVNearestConfigurationPicker.Builder.self),
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
