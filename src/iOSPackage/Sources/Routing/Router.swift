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

  public var viewController: UIViewController { navigationController }

  public private(set) var tabRouting: TabRouting?
  public private(set) var loadingRouting: LoadingRouting?
  public private(set) var sessionRouting: SessionRouting?
  private let tabRoutingFactory: Factory<TabRouting>
  private let loadingRoutingFactory: Factory<LoadingRouting>
  private let sessionRoutingFactory: Factory<SessionRouting>

  public func selectTab(animated: Bool) async {
    if tabRouting != nil {
      if sessionRouting != nil {
        await navigationController.popLast(animated: animated)
        sessionRouting = nil
      }
    } else {
      let tabRouting = tabRoutingFactory.make()
      self.tabRouting = tabRouting
      sessionRouting = nil
      loadingRouting = nil
      tabRouting.selectMain()
      await navigationController.set(viewControllers: [tabRouting.viewController], animated: animated)
    }
  }

  public func selectLoading(animated: Bool) async {
    guard loadingRouting == nil else { return }
    let loadingRouting = loadingRoutingFactory.make()
    self.loadingRouting = loadingRouting
    sessionRouting = nil
    tabRouting = nil
    await navigationController.set(viewControllers: [loadingRouting.viewController], animated: animated)
  }

  public func selectSession(animated: Bool) async {
    if tabRouting != nil {
      if sessionRouting == nil {
        let sessionRouting = sessionRoutingFactory.make()
        self.sessionRouting = sessionRouting
        await navigationController.push(viewController: sessionRouting.viewController, animated: animated)
      }
    } else {
      let tabRouting = tabRoutingFactory.make()
      let sessionRouting = sessionRoutingFactory.make()
      self.tabRouting = tabRouting
      self.sessionRouting = sessionRouting
      loadingRouting = nil
      await navigationController.set(
        viewControllers: [tabRouting.viewController, sessionRouting.viewController],
        animated: animated
      )
    }
  }

  private let navigationController = UINavigationController()
}
