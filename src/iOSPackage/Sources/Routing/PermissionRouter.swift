import CommonUI
import UIKit
import Permissions

@MainActor
public final class PermissionRouter: PermissionRouting {
  public nonisolated init(coordinator: PermissionControllerCoordinating) {
    self.coordinator = coordinator
  }

  private let coordinator: PermissionControllerCoordinating
  public var viewController: UIViewController {
    coordinator.viewController
  }

  public func waitToClose() async {
    await coordinator.waitToClose()
  }
}
