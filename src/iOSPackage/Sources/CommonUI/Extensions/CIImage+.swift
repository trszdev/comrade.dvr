import CoreImage

public extension CIImage {
  func makeCGImage() -> CGImage? {
    let context = CIContext(options: nil)
    return context.createCGImage(self, from: extent)
  }

  static func transparentPixel() -> CIImage! {
    let base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
    let data = Data(base64Encoded: base64)!
    return CIImage(data: data)
  }
}
