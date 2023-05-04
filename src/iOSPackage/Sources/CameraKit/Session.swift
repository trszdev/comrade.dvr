import AVFoundation
import CommonUI

public final class Session: Equatable {
  public static func == (lhs: Session, rhs: Session) -> Bool {
    lhs === rhs
  }

  var singleCameraSession: AVCaptureSession!
  var multiCameraSession: AVCaptureMultiCamSession!

  init(frontCameraSession: AVCaptureSession) {
    self.singleCameraSession = frontCameraSession
    self.frontCameraPreviewView = .init()
  }

  init(backCameraSession: AVCaptureSession) {
    self.singleCameraSession = backCameraSession
    self.backCameraPreviewView = .init()
  }

  init(multiCameraSession: AVCaptureMultiCamSession) {
    self.multiCameraSession = multiCameraSession
    self.frontCameraPreviewView = .init()
    self.backCameraPreviewView = .init()
  }

  let frontOutput = AVCaptureVideoDataOutput()
  let backOutput = AVCaptureVideoDataOutput()
  public private(set) var frontCameraPreviewView: PreviewView?
  public private(set) var backCameraPreviewView: PreviewView?

  var avSession: AVCaptureSession! {
    singleCameraSession ?? multiCameraSession
  }

  var isMulticam: Bool {
    multiCameraSession != nil
  }
}
