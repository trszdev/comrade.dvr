import AVFoundation
import VideoToolbox
import Device

public struct VideoRecorderOptions {
  public init(framesToFlush: Int, configuration: CameraConfiguration, isLandscape: Bool) {
    self.framesToFlush = framesToFlush
    self.configuration = configuration
    self.isLandscape = isLandscape
  }

  public var framesToFlush: Int
  public var configuration: CameraConfiguration
  public var isLandscape: Bool

  var assetWriterInput: AVAssetWriterInput {
    let result = AVAssetWriterInput(mediaType: .video, outputSettings: [
      AVVideoCodecKey: configuration.useH265 && VTIsHardwareDecodeSupported(kCMVideoCodecType_HEVC) ?
      AVVideoCodecType.hevc :
        AVVideoCodecType.h264,
      AVVideoWidthKey: isLandscape ? configuration.resolution.width : configuration.resolution.height,
      AVVideoHeightKey: isLandscape ? configuration.resolution.height : configuration.resolution.width,
      AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: configuration.bitrate.bitsPerSecond,
      ],
    ])
    result.expectsMediaDataInRealTime = true
    return result
  }
}
