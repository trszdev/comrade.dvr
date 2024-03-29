import UIKit
import CommonUI
import Util
import SPStorkController

@MainActor
public final class Router: Routing {
  public nonisolated init(
    tabRoutingFactory: Factory<TabRouting>,
    loadingRoutingFactory: Factory<LoadingRouting>,
    sessionRoutingFactory: @escaping (UIInterfaceOrientation) -> SessionRouting,
    paywallRoutingFactory: Factory<PaywallRouting>
  ) {
    self.tabRoutingFactory = tabRoutingFactory
    self.loadingRoutingFactory = loadingRoutingFactory
    self.sessionRoutingFactory = sessionRoutingFactory
    self.paywallRoutingFactory = paywallRoutingFactory
  }

  public var window: UIWindow?

  public private(set) var tabRouting: TabRouting?
  public private(set) var loadingRouting: LoadingRouting?
  public private(set) var sessionRouting: SessionRouting?
  public private(set) var paywallRouting: PaywallRouting?
  private let tabRoutingFactory: Factory<TabRouting>
  private let loadingRoutingFactory: Factory<LoadingRouting>
  private let sessionRoutingFactory: (UIInterfaceOrientation) -> SessionRouting
  private let paywallRoutingFactory: Factory<PaywallRouting>

  public func selectTab(animated: Bool) async {
    guard tabRouting == nil else { return }
    let tabRouting = tabRoutingFactory.make()
    self.tabRouting = tabRouting
    let needToSlide = sessionRouting != nil
    sessionRouting = nil
    loadingRouting = nil
    tabRouting.selectStart()
    if needToSlide {
      await window?.curlDown(rootViewController: tabRouting.viewController, animated: animated)
    } else {
      await window?.fade(rootViewController: tabRouting.viewController, animated: animated)
    }
  }

  public func selectLoading(animated: Bool) async {
    guard loadingRouting == nil else { return }
    let loadingRouting = loadingRoutingFactory.make()
    self.loadingRouting = loadingRouting
    sessionRouting = nil
    tabRouting = nil
    await window?.fade(rootViewController: loadingRouting.viewController, animated: animated)
  }

  public func selectSession(orientation: UIInterfaceOrientation, animated: Bool) async {
    guard sessionRouting == nil else { return }
    let sessionRouting = sessionRoutingFactory(orientation)
    self.sessionRouting = sessionRouting
    loadingRouting = nil
    tabRouting = nil
    await window?.curlUp(rootViewController: sessionRouting.viewController, animated: animated)
  }

  public func showPaywall(animated: Bool) async {
    guard sessionRouting == nil else { return }
    let paywallRouting = paywallRoutingFactory.make()
    self.paywallRouting = paywallRouting
    let controller = paywallRouting.viewController
    let trackVC = TrackingViewController(controller) {} viewDidDisappear: { [weak self] _ in
      self?.paywallRouting = nil
    }
    let transitionDelegate = SPStorkTransitioningDelegate()
    transitionDelegate.customHeight = 330
    transitionDelegate.showIndicator = false
    transitionDelegate.showCloseButton = true
    trackVC.transitioningDelegate = transitionDelegate
    trackVC.modalPresentationStyle = .custom
    trackVC.modalPresentationCapturesStatusBarAppearance = true
    await window?.rootViewController?.present(viewController: trackVC, animated: animated)
  }
}
