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
