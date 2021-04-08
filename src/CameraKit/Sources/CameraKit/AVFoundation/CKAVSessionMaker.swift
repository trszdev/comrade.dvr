import AutocontainerKit

struct CKAVSessionMaker: CKSessionMaker {
  let configurationMapper: CKAVConfigurationMapper
  let locator: AKLocator

  var adjustableConfiguration: CKAdjustableConfiguration {
    configurationMapper.currentConfiguration
  }

  func makeSession(configuration: CKConfiguration) throws -> CKSession {
    let picker = CKAVNearestConfigurationPicker(adjustableConfiguration: adjustableConfiguration)
    let nearestConf = picker.nearestConfiguration(for: configuration)
    var cameraSession: CKSession?
    var microphoneSession: CKSession?
    if nearestConf.cameras.count < 2 {
      let session = locator.resolve(CKAVSingleCameraSession.Builder.self).makeSession(configuration: nearestConf)
      try session.start()
      cameraSession = session
    } else {
      fatalError("N/A")
    }
    if nearestConf.microphone != nil {
      let session = locator.resolve(CKAVMicrophoneSession.Builder.self).makeSession(configuration: nearestConf)
      try session.start()
      microphoneSession = session
    }
    return CKCombinedSession(sessions: [cameraSession, microphoneSession].compactMap { $0 }, configuration: nearestConf)
  }
}
