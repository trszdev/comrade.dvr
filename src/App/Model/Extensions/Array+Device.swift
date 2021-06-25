import CameraKit

extension Array where Element == Device {
  var configuration: CKConfiguration {
    var cameras = Set<CKDevice<CKCameraConfiguration>>()
    var microphone: CKDevice<CKMicrophoneConfiguration>?
    for device in self {
      switch device {
      case let .camera(cameraDevice):
        guard cameraDevice.isEnabled else { continue }
        cameras.insert(CKDevice(id: cameraDevice.id, configuration: cameraDevice.configuration))
      case let .microphone(microphoneDevice):
        guard microphoneDevice.isEnabled else { continue }
        microphone = CKDevice(id: microphoneDevice.id, configuration: microphoneDevice.configuration)
      }
    }
    return CKConfiguration(cameras: cameras, microphone: microphone)
  }
}
