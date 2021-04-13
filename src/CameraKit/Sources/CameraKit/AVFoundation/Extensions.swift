import AVFoundation

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

extension CKCameraConfiguration {
  var assetWriterInput: AVAssetWriterInput {
    let bitrate: Int
    switch videoQuality {
    case .min:
      bitrate = 230_000
    case .low:
      bitrate = 230_000
    case .medium:
      bitrate = 230_000
    case .high:
      bitrate = 230_000
    case .max:
      bitrate = 230_000
    }
    let result = AVAssetWriterInput(mediaType: .video, outputSettings: [
      AVVideoCodecKey: AVVideoCodecType.h264,
      AVVideoWidthKey: size.width,
      AVVideoHeightKey: size.height,
      AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: bitrate,
      ],
    ])
    result.expectsMediaDataInRealTime = true
    return result
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
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
      ]
    case .low:
      return [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 24000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue,
      ]
    case .medium:
      return [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
      ]
    case .high:
      return [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 48000,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
      ]
    case .max:
      return [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 96000,
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
