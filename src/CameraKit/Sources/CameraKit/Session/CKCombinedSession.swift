import Foundation
import Combine

final class CKCombinedSession: CKSession, CKSessionPublisherProvider {
  let startupInfo = CKSessionStartupInfo()
  let sessionPublisher: CKSessionPublisher

  init(sessions: [CKSession], sessionPublisher: CKSessionPublisher, configuration: CKConfiguration) {
    self.sessions = sessions
    self.cameras = sessions.reduce(into: [:]) { acc, x in acc.merge(x.cameras) { first, _ in first } }
    self.microphone = sessions.first { $0.microphone != nil }?.microphone
    self.configuration = configuration
    self.sessionPublisher = sessionPublisher
  }

  let sessions: [CKSession]
  let cameras: [CKDeviceID: CKCameraDevice]
  let microphone: CKMicrophoneDevice?
  let configuration: CKConfiguration

  var pressureLevel: CKPressureLevel {
    sessions.map(\.pressureLevel).max() ?? .nominal
  }

  func requestMediaChunk() {
    for session in sessions {
      session.requestMediaChunk()
    }
  }
}
