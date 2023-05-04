import Foundation

@MainActor
public protocol HistoryRouting: UIViewControllerProviding, AnyObject {
  var shareRouting: ShareRouting? { get }
  func share(url: URL, animated: Bool) async
}
