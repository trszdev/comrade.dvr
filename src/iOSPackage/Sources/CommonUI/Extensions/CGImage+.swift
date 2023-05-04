import CoreGraphics
import CoreImage

public extension CGImage {
  static func transparentPixel() -> CGImage! {
    CIImage.transparentPixel().makeCGImage()
  }
}
