@MainActor
public protocol DeviceMicrophoneRouting: UIViewControllerProviding, AnyObject {
  func close(animated: Bool) async
}
