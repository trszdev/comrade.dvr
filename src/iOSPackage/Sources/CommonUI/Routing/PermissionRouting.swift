@MainActor
public protocol PermissionRouting: UIViewControllerProviding, AnyObject {
  func waitToClose() async
}
