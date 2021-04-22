import AVFoundation
import VideoToolbox

extension AVCaptureDevice.Format {
  var size: CKSize {
    let fmtDesc = CMVideoFormatDescriptionGetDimensions(formatDescription)
    return CKSize(width: Int(fmtDesc.width), height: Int(fmtDesc.height))
  }
}

extension CMTime {
  var timeInterval: TimeInterval {
    TimeInterval(CMTimeGetSeconds(self))
  }
}

extension CKOrientation {
  var avOrientation: AVCaptureVideoOrientation {
    switch self {
    case .portrait:
      return .portrait
    case .portraitUpsideDown:
      return .portraitUpsideDown
    case .landscapeLeft:
      return .landscapeLeft
    case .landscapeRight:
      return .landscapeRight
    }
  }

  var avStereoOrientation: AVAudioSession.StereoOrientation {
    switch self {
    case .portrait:
      return .portrait
    case .portraitUpsideDown:
      return .portraitUpsideDown
    case .landscapeLeft:
      return .landscapeLeft
    case .landscapeRight:
      return .landscapeRight
    }
  }
}

extension CKStabilizationMode {
  var avStabilizationMode: AVCaptureVideoStabilizationMode {
    switch self {
    case .auto:
      return .auto
    case .cinematic:
      return .cinematic
    case .cinematicExtended:
      return .cinematicExtended
    case .off:
      return .off
    case .standard:
      return .standard
    }
  }
}

extension Optional where Wrapped == AVAudioSession.Orientation {
  var ckDeviceLocation: CKDeviceLocation {
    guard let value = self else { return .unspecified }
    switch value {
    case .back:
      return .back
    case .bottom:
      return .bottom
    case .front:
      return .front
    case .left:
      return .left
    case .right:
      return .right
    case .top:
      return .top
    default:
      return .unspecified
    }
  }
}

extension AVAudioSession.PolarPattern {
  var ckPolarPattern: CKPolarPattern {
    switch self {
    case .stereo:
      return .stereo
    case .omnidirectional:
      return .omnidirectional
    case .cardioid:
      return .cardioid
    case .subcardioid:
      return .subcardioid
    default:
      return .unspecified
    }
  }
}

extension CKQuality {
  var videoQualityMultiplier: Double {
    switch self {
    case .min:
      return 0.3
    case .low:
      return 0.4
    case .medium:
      return 0.6
    case .high:
      return 0.8
    case .max:
      return 1
    }
  }
}

extension CKCameraConfiguration {
  func assetWriterInput(bitsPerPixel: Int) -> AVAssetWriterInput {
    let maxBitrate = size.width * size.height * fps * bitsPerPixel
    let bitrate = max(Int(Double(maxBitrate) * videoQuality.videoQualityMultiplier), 1)
    let result = AVAssetWriterInput(mediaType: .video, outputSettings: [
      AVVideoCodecKey: VTIsHardwareDecodeSupported(kCMVideoCodecType_HEVC) ?
        AVVideoCodecType.hevc :
        AVVideoCodecType.h264,
      AVVideoWidthKey: size.width,
      AVVideoHeightKey: size.height,
      AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: bitrate,
      ],
    ])
    result.transform = transform
    result.expectsMediaDataInRealTime = true
    return result
  }

  var transform: CGAffineTransform {
    switch orientation {
    case .landscapeRight:
      return .identity
    case .landscapeLeft:
      return CGAffineTransform(rotationAngle: .pi)
    case .portrait:
      return CGAffineTransform(rotationAngle: .pi / 2)
    case .portraitUpsideDown:
      return CGAffineTransform(rotationAngle: .pi / -2)
    }
  }
}

extension CKPolarPattern {
  var avPolarPattern: AVAudioSession.PolarPattern? {
    switch self {
    case .cardioid:
      return .cardioid
    case .subcardioid:
      return .subcardioid
    case .omnidirectional:
      return .omnidirectional
    case .stereo:
      return .stereo
    case .unspecified:
      return nil
    }
  }
}

extension AVCaptureDevice {
  var ckPressureLevel: CKPressureLevel {
    switch systemPressureState.level {
    case .nominal, .fair:
      return .nominal
    case .critical, .serious:
      return .serious
    case .shutdown:
      return .shutdown
    default:
      return .nominal
    }
  }
}

extension CKQuality {
  var avAudioRecorderSettings: [String: Any] {
    switch self {
    case .min:
      return [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
      ]
    case .low:
      return [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue,
      ]
    case .medium:
      return [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
      ]
    case .high:
      return [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
      ]
    case .max:
      return [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
      ]
    }
  }
}

extension CKVideoGravity {
  var avVideoGravity: AVLayerVideoGravity {
    switch self {
    case .resize:
      return .resize
    case .resizeAspect:
      return .resizeAspect
    case .resizeAspectFill:
      return .resizeAspectFill
    }
  }
}

extension CKMediaType {
  var infoPlistKey: String {
    switch self {
    case .audio:
      return "NSMicrophoneUsageDescription"
    case .video:
      return "NSCameraUsageDescription"
    }
  }

  var avMediaType: AVMediaType {
    switch self {
    case .audio:
      return .audio
    case .video:
      return .video
    }
  }
}

func clamp<T: Comparable>(lower: T, value: T, upper: T) -> T {
  min(max(value, lower), upper)
}
