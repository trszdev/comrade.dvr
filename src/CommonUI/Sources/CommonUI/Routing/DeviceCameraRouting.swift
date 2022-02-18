@MainActor
public protocol DeviceCameraRouting: UIViewControllerProviding, AnyObject {
  func close(animated: Bool) async
}
