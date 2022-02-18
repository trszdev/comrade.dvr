import UIKit
import CommonUI
import Util

@MainActor
final class MainRouter: MainRouting {
  private(set) var deviceCameraRouting: DeviceCameraRouting?
  private(set) var deviceMicrophoneRouting: DeviceMicrophoneRouting?

  nonisolated init(
    rootViewController: UIViewController,
    navigationController: UINavigationController,
    deviceCameraRoutingFactory: Factory<DeviceCameraRouting>,
    deviceMicrophoneRoutingFactory: Factory<DeviceMicrophoneRouting>
  ) {
    self.rootViewController = rootViewController
    self.navigationController = navigationController
    self.deviceCameraRoutingFactory = deviceCameraRoutingFactory
    self.deviceMicrophoneRoutingFactory = deviceMicrophoneRoutingFactory
  }

  func openDeviceCamera(animated: Bool) async {
    guard self.deviceCameraRouting == nil else { return }
    let deviceCameraRouting = deviceCameraRoutingFactory.make()
    self.deviceCameraRouting = deviceCameraRouting
    deviceMicrophoneRouting = nil
    let viewController = deviceCameraRouting.viewController
    viewController.deinitCallback().callback = { [weak self] in
      self?.deviceCameraRouting = nil
    }
    await navigationController.set(viewControllers: [rootViewController, viewController], animated: animated)
  }

  func openDeviceMicrophone(animated: Bool) async {
    guard self.deviceMicrophoneRouting == nil else { return }
    let deviceMicrophoneRouting = deviceMicrophoneRoutingFactory.make()
    self.deviceMicrophoneRouting = deviceMicrophoneRouting
    deviceCameraRouting = nil
    let viewController = deviceMicrophoneRouting.viewController
    viewController.deinitCallback().callback = { [weak self] in
      self?.deviceMicrophoneRouting = nil
    }
    await navigationController.set(viewControllers: [rootViewController, viewController], animated: animated)
  }

  var viewController: UIViewController {
    navigationController
  }

  private let rootViewController: UIViewController
  private let navigationController: UINavigationController
  private let deviceCameraRoutingFactory: Factory<DeviceCameraRouting>
  private let deviceMicrophoneRoutingFactory: Factory<DeviceMicrophoneRouting>
}
