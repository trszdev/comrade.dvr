@MainActor
public protocol MainRouting: UIViewControllerProviding, AnyObject {
  var deviceCameraRouting: DeviceCameraRouting? { get }
  var deviceMicrophoneRouting: DeviceMicrophoneRouting? { get }
  func openDeviceCamera(animated: Bool) async
  func openDeviceMicrophone(animated: Bool) async
}
