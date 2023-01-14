import AVFoundation
import VideoToolbox
import Device

extension CameraConfiguration {
  var assetWriterInput: AVAssetWriterInput {
    let result = AVAssetWriterInput(mediaType: .video, outputSettings: [
      AVVideoCodecKey: useH265 && VTIsHardwareDecodeSupported(kCMVideoCodecType_HEVC) ?
        AVVideoCodecType.hevc :
        AVVideoCodecType.h264,
      AVVideoWidthKey: resolution.width,
      AVVideoHeightKey: resolution.height,
      AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: bitrate.bitsPerSecond,
      ],
    ])
    result.expectsMediaDataInRealTime = true
    return result
  }
}
