import AVFoundation

public protocol SessionProvider {
  var singleCameraSession: AVCaptureSession? { get }
  var dualCameraSession: AVCaptureMultiCamSession? { get }
}
