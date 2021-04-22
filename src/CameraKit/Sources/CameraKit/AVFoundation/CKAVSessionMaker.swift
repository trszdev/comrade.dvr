struct CKAVSessionMaker: CKSessionMaker {
  let configurationMapper: CKAVConfigurationMapper
  let cameraSessionBuilder: CKAVCameraSession.Builder
  let microphoneSessionBuilder: CKAVMicrophoneSession.Builder
  let nearestConfigurationPickerBuilder: CKAVNearestConfigurationPicker.Builder

  var configurationPicker: CKNearestConfigurationPicker {
    nearestConfigurationPickerBuilder.makePicker(adjustableConfiguration: adjustableConfiguration)
  }

  var adjustableConfiguration: CKAdjustableConfiguration {
    configurationMapper.currentConfiguration
  }

  func makeSession(configuration: CKConfiguration) throws -> CKSession {
    let nearestConf = configurationPicker.nearestConfiguration(for: configuration)
    var sessions = [CKSession]()
    let cameraSession = cameraSessionBuilder.makeSession(configuration: nearestConf)
    try cameraSession.start()
    sessions.append(cameraSession)
    if nearestConf.microphone != nil {
      let session = microphoneSessionBuilder.makeSession(configuration: nearestConf)
      try session.start()
      sessions.append(session)
    }
    return CKCombinedSession(sessions: sessions, configuration: nearestConf)
  }
}
