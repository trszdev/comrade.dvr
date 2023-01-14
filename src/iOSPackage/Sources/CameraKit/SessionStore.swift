import AVFoundation

public final class SessionStore {
  @Published public private(set) var session: Session?

  func recreateSession(backCamera: Any?, frontCamera: Any?) {
    session?.currentSession?.stopRunning()
    if backCamera != nil, frontCamera != nil {
      session = .init(multiCameraSession: .init())
    } else {
      session = .init(singleCameraSession: .init())
    }
  }
}
