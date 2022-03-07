import CommonUI
import UIKit
import Util

@MainActor
public final class HistoryRouter: HistoryRouting {
  public var shareRouting: ShareRouting?

  public func share(animated: Bool) async {
    guard shareRouting == nil else { return }
    let shareRouting = shareRoutingFactory.make()
    self.shareRouting = shareRouting
    TrackingViewController.installOnParent(shareRouting.viewController) {} viewDidDisappear: { [weak self] _ in
      self?.shareRouting = nil
    }
    await viewController.present(viewController: shareRouting.viewController, animated: animated)
  }

  public nonisolated init(viewController: UIViewController, shareRoutingFactory: Factory<ShareRouting>) {
    self.viewController = viewController
    self.shareRoutingFactory = shareRoutingFactory
  }

  public let viewController: UIViewController
  private let shareRoutingFactory: Factory<ShareRouting>
}
