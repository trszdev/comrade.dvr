import AVFoundation
import UIKit

final class AVPreviewView: UIView {
  override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
  }

  var videoPreviewLayer: AVCaptureVideoPreviewLayer! {
    layer as? AVCaptureVideoPreviewLayer
  }
}
