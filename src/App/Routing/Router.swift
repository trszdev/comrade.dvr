import UIKit
import CommonUI
import Util

@MainActor
final class Router: Routing {
  nonisolated init(
    tabRoutingFactory: Factory<TabRouting>,
    loadingRoutingFactory: Factory<LoadingRouting>,
    sessionRoutingFactory: Factory<SessionRouting>
  ) {
    self.tabRoutingFactory = tabRoutingFactory
    self.loadingRoutingFactory = loadingRoutingFactory
    self.sessionRoutingFactory = sessionRoutingFactory
  }

  var viewController: UIViewController { navigationController }

  private(set) var tabRouting: TabRouting?
  private(set) var loadingRouting: LoadingRouting?
  private(set) var sessionRouting: SessionRouting?
  private let tabRoutingFactory: Factory<TabRouting>
  private let loadingRoutingFactory: Factory<LoadingRouting>
  private let sessionRoutingFactory: Factory<SessionRouting>

  func selectTab(animated: Bool) async {
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

  func selectLoading(animated: Bool) async {
    guard loadingRouting == nil else { return }
    let loadingRouting = loadingRoutingFactory.make()
    self.loadingRouting = loadingRouting
    sessionRouting = nil
    tabRouting = nil
    await navigationController.set(viewControllers: [loadingRouting.viewController], animated: animated)
  }

  func selectSession(animated: Bool) async {
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
