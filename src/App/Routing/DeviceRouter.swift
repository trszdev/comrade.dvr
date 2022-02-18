import CommonUI
import UIKit

@MainActor
final class DeviceRouter: DeviceCameraRouting, DeviceMicrophoneRouting {
  nonisolated init(navigationController: UINavigationController, viewController: UIViewController) {
    self.navigationController = navigationController
    self.viewController = viewController
  }

  func close(animated: Bool) async {
    await navigationController?.popLast(animated: animated)
  }

  let viewController: UIViewController
  private weak var navigationController: UINavigationController?
}
