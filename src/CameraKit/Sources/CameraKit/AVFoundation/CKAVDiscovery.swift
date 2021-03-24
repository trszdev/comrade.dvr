import AVFoundation

protocol CKAVDiscovery {
  var microphone: AVCaptureDevice? { get }
  var backCameras: [AVCaptureDevice] { get }
  var frontCameras: [AVCaptureDevice] { get }
}

struct CKAVDiscoveryImpl: CKAVDiscovery {
  var microphone: AVCaptureDevice? {
    AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInMicrophone],
      mediaType: .audio,
      position: .unspecified
    ).devices.first
  }

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
