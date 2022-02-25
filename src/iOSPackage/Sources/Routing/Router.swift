import UIKit
import CommonUI
import Util

@MainActor
public final class Router: Routing {
  public nonisolated init(
    tabRoutingFactory: Factory<TabRouting>,
    loadingRoutingFactory: Factory<LoadingRouting>,
    sessionRoutingFactory: Factory<SessionRouting>
  ) {
    self.tabRoutingFactory = tabRoutingFactory
    self.loadingRoutingFactory = loadingRoutingFactory
    self.sessionRoutingFactory = sessionRoutingFactory
  }

  public var window: UIWindow?

  public private(set) var tabRouting: TabRouting?
  public private(set) var loadingRouting: LoadingRouting?
  public private(set) var sessionRouting: SessionRouting?
  private let tabRoutingFactory: Factory<TabRouting>
  private let loadingRoutingFactory: Factory<LoadingRouting>
  private let sessionRoutingFactory: Factory<SessionRouting>

  public func selectTab(animated: Bool) async {
    guard tabRouting == nil else { return }
    let tabRouting = tabRoutingFactory.make()
    self.tabRouting = tabRouting
    sessionRouting = nil
    loadingRouting = nil
    tabRouting.selectStart()
    await window?.set(rootViewController: tabRouting.viewController, animated: animated)
  }

  public func selectLoading(animated: Bool) async {
    guard loadingRouting == nil else { return }
    let loadingRouting = loadingRoutingFactory.make()
    self.loadingRouting = loadingRouting
    sessionRouting = nil
    tabRouting = nil
    await window?.set(rootViewController: loadingRouting.viewController, animated: animated)
  }

  public func selectSession(animated: Bool) async {
    guard sessionRouting == nil else { return }
    let sessionRouting = sessionRoutingFactory.make()
    self.sessionRouting = sessionRouting
    loadingRouting = nil
    tabRouting = nil
    await window?.set(rootViewController: sessionRouting.viewController, animated: animated)
  }
}
