import CommonUI
import UIKit

@MainActor
public final class DeviceRouter: DeviceCameraRouting, DeviceMicrophoneRouting {
  public nonisolated init(navigationController: UINavigationController, viewController: UIViewController) {
    self.navigationController = navigationController
    self.viewController = viewController
  }

  public func close(animated: Bool) async {
    await navigationController?.popLast(animated: animated)
  }

  public let viewController: UIViewController
  private weak var navigationController: UINavigationController?
}
