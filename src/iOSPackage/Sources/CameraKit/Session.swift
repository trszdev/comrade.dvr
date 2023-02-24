import AVFoundation

public final class Session {
  var singleCameraSession: AVCaptureSession!
  var multiCameraSession: AVCaptureMultiCamSession!

  init(singleCameraSession: AVCaptureSession) {
    self.singleCameraSession = singleCameraSession
  }

  init(multiCameraSession: AVCaptureMultiCamSession) {
    self.multiCameraSession = multiCameraSession
  }

  public let frontOutput = AVCaptureVideoDataOutput()
  public let backOutput = AVCaptureVideoDataOutput()
  public let frontCameraPreviewView = PreviewView()
  public let backCameraPreviewView = PreviewView()

  var avSession: AVCaptureSession! {
    singleCameraSession ?? multiCameraSession
  }

  var isMulticam: Bool {
    multiCameraSession != nil
  }
}
