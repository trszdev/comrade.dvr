import CommonUI
import UIKit

@MainActor
public final class StubRouter: SettingsRouting, ShareRouting, SessionRouting, LoadingRouting {
  public nonisolated init(viewController: UIViewController) {
    self.viewController = viewController
  }

  public let viewController: UIViewController
}
