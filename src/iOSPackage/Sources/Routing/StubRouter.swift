import CommonUI
import UIKit

@MainActor
public final class StubRouter: PaywallRouting, ShareRouting, SessionRouting, LoadingRouting, SettingsRouting {
  public nonisolated init(viewController: UIViewController) {
    self.viewController = viewController
  }

  public let viewController: UIViewController
}
