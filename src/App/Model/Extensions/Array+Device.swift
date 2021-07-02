import CameraKit

extension Array where Element == Device {
  func configuration(orientation: CKOrientation? = nil) -> CKConfiguration {
    var cameras = Set<CKDevice<CKCameraConfiguration>>()
    var microphone: CKDevice<CKMicrophoneConfiguration>?
    for device in self {
      switch device {
      case var .camera(cameraDevice):
        guard cameraDevice.isEnabled else { continue }
        if let orientation = orientation {
          cameraDevice.configuration.orientation = orientation
        }
        cameras.insert(CKDevice(id: cameraDevice.id, configuration: cameraDevice.configuration))
      case var .microphone(microphoneDevice):
        guard microphoneDevice.isEnabled else { continue }
        if let orientation = orientation {
          microphoneDevice.configuration.orientation = orientation
        }
        microphone = CKDevice(id: microphoneDevice.id, configuration: microphoneDevice.configuration)
      }
    }
    return CKConfiguration(cameras: cameras, microphone: microphone)
  }
}
