@MainActor
public protocol Routing: UIViewControllerProviding, AnyObject {
  var tabRouting: TabRouting? { get }
  var loadingRouting: LoadingRouting? { get }
  var sessionRouting: SessionRouting? { get }
  var paywallRouting: PaywallRouting? { get }
  func selectTab(animated: Bool) async
  func selectLoading(animated: Bool) async
  func selectSession(animated: Bool) async
  func showPaywall(animated: Bool) async
}
