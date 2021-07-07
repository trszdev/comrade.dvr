import AutocontainerKit

struct CKAVSessionMaker: CKSessionMaker {
  final class Builder: AKBuilder {
    func makeSessionMaker(configurationPicker: CKNearestConfigurationPicker) -> CKSessionMaker {
      CKAVSessionMaker(
        cameraSessionBuilder: resolve(CKAVCameraSession.Builder.self),
        microphoneSessionBuilder: resolve(CKAVMicrophoneSession.Builder.self),
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
