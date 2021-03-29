public protocol CKConfigurationKind {
  associatedtype CameraConfiguration: Hashable
  associatedtype MicrophoneConfiguration: Hashable
  var cameras: [CKDeviceID: CKDevice<CameraConfiguration>] { get }
  var microphone: CKDevice<MicrophoneConfiguration>? { get }
}

public extension CKConfigurationKind {
  var backCamera: CKDevice<CameraConfiguration>? {
    cameras[CKCameraDeviceID.back]
  }

  var frontCamera: CKDevice<CameraConfiguration>? {
    cameras[CKCameraDeviceID.front]
  }
}
