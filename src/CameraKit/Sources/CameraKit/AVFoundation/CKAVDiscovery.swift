import AVFoundation

protocol CKAVDiscovery {
  var backCameras: [AVCaptureDevice] { get }
  var frontCameras: [AVCaptureDevice] { get }
  var audioInputs: [AVAudioSessionPortDescription] { get }
  var multiCameraDeviceSets: [Set<AVCaptureDevice>] { get }
}

public struct CKAVDiscoveryImpl: CKAVDiscovery {
  let audioSession: AVAudioSession

  var backCameras: [AVCaptureDevice] {
    AVCaptureDevice.DiscoverySession(
      deviceTypes: cameraDeviceTypes,
      mediaType: .video,
      position: .back
    ).devices
  }

  var frontCameras: [AVCaptureDevice] {
    AVCaptureDevice.DiscoverySession(
      deviceTypes: cameraDeviceTypes,
      mediaType: .video,
      position: .front
    ).devices
  }

  var audioInputs: [AVAudioSessionPortDescription] {
    audioSession.availableInputs ?? []
  }

  var multiCameraDeviceSets: [Set<AVCaptureDevice>] {
    AVCaptureDevice.DiscoverySession(
      deviceTypes: cameraDeviceTypes,
      mediaType: .video,
      position: .unspecified
    )
    .supportedMultiCamDeviceSets
    .filter { $0.count > 1 }
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
