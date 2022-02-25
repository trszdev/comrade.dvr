import UIKit
import CommonUI
import Util

@MainActor
public final class StartRouter: StartRouting {
  public private(set) var deviceCameraRouting: DeviceCameraRouting?
  public private(set) var deviceMicrophoneRouting: DeviceMicrophoneRouting?

  public nonisolated init(
    rootViewController: UIViewController,
    navigationController: UINavigationController,
    deviceCameraRoutingFactory: Factory<DeviceCameraRouting>,
    deviceMicrophoneRoutingFactory: Factory<DeviceMicrophoneRouting>
  ) {
    self.rootViewController = rootViewController
    self.navigationController = navigationController
    self.deviceCameraRoutingFactory = deviceCameraRoutingFactory
    self.deviceMicrophoneRoutingFactory = deviceMicrophoneRoutingFactory
    Task { @MainActor in
      navigationController.viewControllers = [rootViewController]
    }
  }

  public func openDeviceCamera(animated: Bool) async {
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

  public func openDeviceMicrophone(animated: Bool) async {
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

  public var viewController: UIViewController {
    navigationController
  }

  private let rootViewController: UIViewController
  private let navigationController: UINavigationController
  private let deviceCameraRoutingFactory: Factory<DeviceCameraRouting>
  private let deviceMicrophoneRoutingFactory: Factory<DeviceMicrophoneRouting>
}
