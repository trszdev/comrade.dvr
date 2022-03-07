import CommonUI
import UIKit
import SPPermissions
import SPPermissionsCamera
import Assets

@MainActor
public final class SettingsRouter: SettingsRouting {
  public nonisolated init(viewController: UIViewController) {
    self.viewController = viewController
  }

  public func showNotificationPermission() async {

  }

  public let viewController: UIViewController
}
