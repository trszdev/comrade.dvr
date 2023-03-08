import AVFoundation

public struct Discovery {
  public init(audioSession: AVAudioSession = .sharedInstance()) {
    self.audioSession = audioSession
  }

  var audioSession: AVAudioSession = .sharedInstance()

  public var backCameras: [AVCaptureDevice] {
    AVCaptureDevice.DiscoverySession(
      deviceTypes: cameraDeviceTypes,
      mediaType: .video,
      position: .back
    ).devices
  }

  public var frontCameras: [AVCaptureDevice] {
    AVCaptureDevice.DiscoverySession(
      deviceTypes: cameraDeviceTypes,
      mediaType: .video,
      position: .front
    ).devices
  }

  public var builtInMic: AVAudioSessionPortDescription? {
    (audioSession.availableInputs ?? []).first { $0.portType == .builtInMic }
  }

  var multiCameraDeviceSets: [(AVCaptureDevice, AVCaptureDevice)] {
    AVCaptureDevice.DiscoverySession(
      deviceTypes: cameraDeviceTypes,
      mediaType: .video,
      position: .unspecified
    )
    .supportedMultiCamDeviceSets
    .compactMap { cameraSet in
      let frontCamera = cameraSet.first { $0.position == .front }
      let backCamera = cameraSet.first { $0.position == .back }

      return frontCamera == nil || backCamera == nil ? nil : (frontCamera!, backCamera!)
    }
  }
}

private let cameraDeviceTypes: [AVCaptureDevice.DeviceType] = [
  .builtInDualCamera,
  .builtInTripleCamera,
  .builtInTelephotoCamera,
  .builtInDualWideCamera,
  .builtInDualWideCamera,
  .builtInWideAngleCamera,
  .builtInUltraWideCamera,
  .builtInTrueDepthCamera,
]
