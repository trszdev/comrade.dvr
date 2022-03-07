import AVFoundation

@MainActor
public protocol SessionManager {
  var session: AVCaptureSession? { get }
  func start()
  func stop()
}
