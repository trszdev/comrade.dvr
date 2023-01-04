@MainActor
public protocol HistoryRouting: UIViewControllerProviding, AnyObject {
  var shareRouting: ShareRouting? { get }
  func share(animated: Bool) async
}
