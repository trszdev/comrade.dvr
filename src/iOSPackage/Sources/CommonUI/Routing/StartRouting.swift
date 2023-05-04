@MainActor
public protocol StartRouting: UIViewControllerProviding, AnyObject {
  var deviceCameraRouting: DeviceCameraRouting? { get }
  var deviceMicrophoneRouting: DeviceMicrophoneRouting? { get }
  var permissionRouting: PermissionRouting? { get }
  func openDeviceCamera(animated: Bool) async
  func openDeviceMicrophone(animated: Bool) async
  func showPermissions(animated: Bool) async
}
