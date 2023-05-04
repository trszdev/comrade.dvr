import AVFoundation
import UIKit

public final class PreviewView: UIView {
  public override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
  }

  var videoPreviewLayer: AVCaptureVideoPreviewLayer! {
    layer as? AVCaptureVideoPreviewLayer
  }
}
