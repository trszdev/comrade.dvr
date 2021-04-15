import AVFoundation

let pixelFormats: [String: OSType] = [
  "kCVPixelFormatType_1Monochrome": kCVPixelFormatType_1Monochrome,
  "kCVPixelFormatType_2Indexed": kCVPixelFormatType_2Indexed,
  "kCVPixelFormatType_4Indexed": kCVPixelFormatType_4Indexed,
  "kCVPixelFormatType_8Indexed": kCVPixelFormatType_8Indexed,
  "kCVPixelFormatType_1IndexedGray_WhiteIsZero": kCVPixelFormatType_1IndexedGray_WhiteIsZero,
  "kCVPixelFormatType_2IndexedGray_WhiteIsZero": kCVPixelFormatType_2IndexedGray_WhiteIsZero,
  "kCVPixelFormatType_4IndexedGray_WhiteIsZero": kCVPixelFormatType_4IndexedGray_WhiteIsZero,
  "kCVPixelFormatType_8IndexedGray_WhiteIsZero": kCVPixelFormatType_8IndexedGray_WhiteIsZero,
  "kCVPixelFormatType_16BE555": kCVPixelFormatType_16BE555,
  "kCVPixelFormatType_16LE555": kCVPixelFormatType_16LE555,
  "kCVPixelFormatType_16LE5551": kCVPixelFormatType_16LE5551,
  "kCVPixelFormatType_16BE565": kCVPixelFormatType_16BE565,
  "kCVPixelFormatType_16LE565": kCVPixelFormatType_16LE565,
  "kCVPixelFormatType_24RGB": kCVPixelFormatType_24RGB,
  "kCVPixelFormatType_24BGR": kCVPixelFormatType_24BGR,
  "kCVPixelFormatType_32ARGB": kCVPixelFormatType_32ARGB,
  "kCVPixelFormatType_32BGRA": kCVPixelFormatType_32BGRA,
  "kCVPixelFormatType_32ABGR": kCVPixelFormatType_32ABGR,
  "kCVPixelFormatType_32RGBA": kCVPixelFormatType_32RGBA,
  "kCVPixelFormatType_64ARGB": kCVPixelFormatType_64ARGB,
  "kCVPixelFormatType_48RGB": kCVPixelFormatType_48RGB,
  "kCVPixelFormatType_32AlphaGray": kCVPixelFormatType_32AlphaGray,
  "kCVPixelFormatType_16Gray": kCVPixelFormatType_16Gray,
  "kCVPixelFormatType_30RGB": kCVPixelFormatType_30RGB,
  "kCVPixelFormatType_422YpCbCr8": kCVPixelFormatType_422YpCbCr8,
  "kCVPixelFormatType_4444YpCbCrA8": kCVPixelFormatType_4444YpCbCrA8,
  "kCVPixelFormatType_4444YpCbCrA8R": kCVPixelFormatType_4444YpCbCrA8R,
  "kCVPixelFormatType_4444AYpCbCr8": kCVPixelFormatType_4444AYpCbCr8,
  "kCVPixelFormatType_4444AYpCbCr16": kCVPixelFormatType_4444AYpCbCr16,
  "kCVPixelFormatType_444YpCbCr8": kCVPixelFormatType_444YpCbCr8,
  "kCVPixelFormatType_422YpCbCr16": kCVPixelFormatType_422YpCbCr16,
  "kCVPixelFormatType_422YpCbCr10": kCVPixelFormatType_422YpCbCr10,
  "kCVPixelFormatType_444YpCbCr10": kCVPixelFormatType_444YpCbCr10,
  "kCVPixelFormatType_420YpCbCr8PlanarFullRange": kCVPixelFormatType_420YpCbCr8PlanarFullRange,
  "kCVPixelFormatType_422YpCbCr_4A_8BiPlanar": kCVPixelFormatType_422YpCbCr_4A_8BiPlanar,
  "kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange": kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
  "kCVPixelFormatType_420YpCbCr8BiPlanarFullRange": kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
  "kCVPixelFormatType_422YpCbCr8_yuvs": kCVPixelFormatType_422YpCbCr8_yuvs,
  "kCVPixelFormatType_422YpCbCr8FullRange": kCVPixelFormatType_422YpCbCr8FullRange,
  "kCVPixelFormatType_OneComponent8": kCVPixelFormatType_OneComponent8,
  "kCVPixelFormatType_TwoComponent8": kCVPixelFormatType_TwoComponent8,
  "kCVPixelFormatType_OneComponent16Half": kCVPixelFormatType_OneComponent16Half,
  "kCVPixelFormatType_OneComponent32Float": kCVPixelFormatType_OneComponent32Float,
  "kCVPixelFormatType_TwoComponent16Half": kCVPixelFormatType_TwoComponent16Half,
  "kCVPixelFormatType_TwoComponent32Float": kCVPixelFormatType_TwoComponent32Float,
  "kCVPixelFormatType_64RGBAHalf": kCVPixelFormatType_64RGBAHalf,
  "kCVPixelFormatType_128RGBAFloat": kCVPixelFormatType_128RGBAFloat,
  "kCVPixelFormatType_14Bayer_BGGR": kCVPixelFormatType_14Bayer_BGGR,
  "kCVPixelFormatType_14Bayer_GBRG": kCVPixelFormatType_14Bayer_GBRG,
  "kCVPixelFormatType_14Bayer_GRBG": kCVPixelFormatType_14Bayer_GRBG,
  "kCVPixelFormatType_14Bayer_RGGB": kCVPixelFormatType_14Bayer_RGGB,
  "kCVPixelFormatType_30RGBLEPackedWideGamut": kCVPixelFormatType_30RGBLEPackedWideGamut,
  "kCVPixelFormatType_ARGB2101010LEPacked": kCVPixelFormatType_ARGB2101010LEPacked,
  "kCVPixelFormatType_420YpCbCr10BiPlanarFullRange": kCVPixelFormatType_420YpCbCr10BiPlanarFullRange,
  "kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange": kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange,
  "kCVPixelFormatType_422YpCbCr10BiPlanarFullRange": kCVPixelFormatType_422YpCbCr10BiPlanarFullRange,
  "kCVPixelFormatType_422YpCbCr10BiPlanarVideoRange": kCVPixelFormatType_422YpCbCr10BiPlanarVideoRange,
  "kCVPixelFormatType_444YpCbCr10BiPlanarFullRange": kCVPixelFormatType_444YpCbCr10BiPlanarFullRange,
  "kCVPixelFormatType_444YpCbCr10BiPlanarVideoRange": kCVPixelFormatType_444YpCbCr10BiPlanarVideoRange,
  "kCVPixelFormatType_DepthFloat16": kCVPixelFormatType_DepthFloat16,
  "kCVPixelFormatType_DepthFloat32": kCVPixelFormatType_DepthFloat32,
  "kCVPixelFormatType_DisparityFloat16": kCVPixelFormatType_DisparityFloat16,
  "kCVPixelFormatType_DisparityFloat32": kCVPixelFormatType_DisparityFloat32,
]

let pixelFormatsReversed = Dictionary(uniqueKeysWithValues: pixelFormats.map { ($0.value, $0.key) })

extension AVCaptureVideoDataOutput {
  var availableVideoPixelFormatNames: [String] {
    availableVideoPixelFormatTypes.map { pixelFormatsReversed[$0] ?? "Unknown" }
  }

  func setPixelFormat(_ format: OSType) {
    videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: format]
  }
}
