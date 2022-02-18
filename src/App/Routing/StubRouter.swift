import CommonUI
import UIKit

@MainActor
final class StubRouter: SettingsRouting, HistoryRouting, SessionRouting, LoadingRouting {
  nonisolated init(viewController: UIViewController) {
    self.viewController = viewController
  }

  let viewController: UIViewController
}
