import Foundation

final class CKCombinedSession: CKSession {
  let startupInfo = CKSessionStartupInfo()

  init(sessions: [CKSession], configuration: CKConfiguration) {
    self.sessions = sessions
    self.cameras = sessions.reduce(into: [:]) { acc, x in acc.merge(x.cameras) { first, _ in first } }
    self.microphone = sessions.first { $0.microphone != nil }?.microphone
    self.configuration = configuration
    for session in sessions {
      session.delegate = self
    }
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

  weak var delegate: CKSessionDelegate?
}

extension CKCombinedSession: CKSessionDelegate {
  func sessionDidChangePressureLevel() {
    delegate?.sessionDidChangePressureLevel()
  }

  func sessionDidOutput(mediaChunk: CKMediaChunk) {
    delegate?.sessionDidOutput(mediaChunk: mediaChunk)
  }

  func sessionDidOutput(error: Error) {
    delegate?.sessionDidOutput(error: error)
  }
}
