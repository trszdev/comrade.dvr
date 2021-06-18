struct CKAVSessionMaker: CKSessionMaker {
  struct Builder {
    let cameraSessionBuilder: CKAVCameraSession.Builder
    let microphoneSessionBuilder: CKAVMicrophoneSession.Builder

    func makeSessionMaker(configurationPicker: CKNearestConfigurationPicker) -> CKSessionMaker {
      CKAVSessionMaker(
        cameraSessionBuilder: cameraSessionBuilder,
        microphoneSessionBuilder: microphoneSessionBuilder,
        configurationPicker: configurationPicker
      )
    }
  }

  let cameraSessionBuilder: CKAVCameraSession.Builder
  let microphoneSessionBuilder: CKAVMicrophoneSession.Builder
  let configurationPicker: CKNearestConfigurationPicker

  func makeSession(configuration: CKConfiguration) throws -> CKSession {
    let nearestConf = configurationPicker.nearestConfiguration(for: configuration)
    var sessions = [CKSession]()
    let sessionPublisher = CKSessionPublisher()
    let cameraSession = cameraSessionBuilder.makeSession(configuration: nearestConf, sessionPublisher: sessionPublisher)
    try cameraSession.start()
    sessions.append(cameraSession)
    if nearestConf.microphone != nil {
      let session = microphoneSessionBuilder.makeSession(configuration: nearestConf, sessionPublisher: sessionPublisher)
      try session.start()
      sessions.append(session)
    }
    return CKCombinedSession(sessions: sessions, sessionPublisher: sessionPublisher, configuration: nearestConf)
  }
}
