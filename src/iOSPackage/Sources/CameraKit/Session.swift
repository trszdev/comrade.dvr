import AVFoundation

public final class Session: Equatable {
  public static func == (lhs: Session, rhs: Session) -> Bool {
    lhs === rhs
  }

  var singleCameraSession: AVCaptureSession!
  var multiCameraSession: AVCaptureMultiCamSession!

  init(singleCameraSession: AVCaptureSession) {
    self.singleCameraSession = singleCameraSession
  }

  init(multiCameraSession: AVCaptureMultiCamSession) {
    self.multiCameraSession = multiCameraSession
  }

  let frontOutput = AVCaptureVideoDataOutput()
  let backOutput = AVCaptureVideoDataOutput()
  public internal(set) var frontCameraPreviewView: PreviewView?
  public internal(set) var backCameraPreviewView: PreviewView?

  var avSession: AVCaptureSession! {
    singleCameraSession ?? multiCameraSession
  }

  var isMulticam: Bool {
    multiCameraSession != nil
  }
}
