import AutocontainerKit

struct CKAVSessionMaker: CKSessionMaker {
  let configurationMapper: CKAVConfigurationMapper
  let locator: AKLocator

  var adjustableConfiguration: CKAdjustableConfiguration {
    configurationMapper.currentConfiguration
  }

  var nearestConfigurationPicker: CKNearestConfigurationPicker {
    CKAVNearestConfigurationPicker(adjustableConfiguration: adjustableConfiguration)
  }

  func makeSession(configuration: CKConfiguration) -> CKSession {
    if configuration.cameras.count < 2 {
      return locator.resolve(CKAVSingleCameraSession.Builder.self).makeSession(configuration: configuration)
    } else {
      fatalError()
    }
  }
}
