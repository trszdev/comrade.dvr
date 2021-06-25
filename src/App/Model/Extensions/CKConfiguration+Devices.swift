import CameraKit

extension CKConfiguration {
  func device(device: Device) -> Device {
    switch device {
    case var .camera(cameraDevice):
      if let exist = cameras[cameraDevice.id] {
        cameraDevice.configuration = exist.configuration
      } else {
        cameraDevice.isEnabled = false
      }
      return .camera(device: cameraDevice)
    case var .microphone(microphoneDevice):
      if let microphone = microphone, microphone.id == microphoneDevice.id {
        microphoneDevice.configuration = microphone.configuration
      } else {
        microphoneDevice.isEnabled = false
      }
      return .microphone(device: microphoneDevice)
    }
  }
}
