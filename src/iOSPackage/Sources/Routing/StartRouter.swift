import UIKit
import CommonUI
import Util
import Assets

@MainActor
public final class StartRouter: StartRouting {
  public private(set) var deviceCameraRouting: DeviceCameraRouting?
  public private(set) var deviceMicrophoneRouting: DeviceMicrophoneRouting?
  public private(set) var permissionRouting: PermissionRouting?

  public nonisolated init(
    rootViewController: UIViewController,
    navigationController: UINavigationController,
    deviceCameraRoutingFactory: Factory<DeviceCameraRouting>,
    deviceMicrophoneRoutingFactory: Factory<DeviceMicrophoneRouting>,
    permissionRoutingFactory: Factory<PermissionRouting>
  ) {
    self.rootViewController = rootViewController
    self.navigationController = navigationController
    self.deviceCameraRoutingFactory = deviceCameraRoutingFactory
    self.deviceMicrophoneRoutingFactory = deviceMicrophoneRoutingFactory
    self.permissionRoutingFactory = permissionRoutingFactory
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
    TrackingViewController.installOnParent(viewController) {} viewDidDisappear: { [weak self] _ in
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
    TrackingViewController.installOnParent(viewController) {} viewDidDisappear: { [weak self] _ in
      self?.deviceMicrophoneRouting = nil
    }
    await navigationController.set(viewControllers: [rootViewController, viewController], animated: animated)
  }

  public func showPermissions(animated: Bool) async {
    guard self.permissionRouting == nil else { return }
    let permissionRouting = permissionRoutingFactory.make()
    self.permissionRouting = permissionRouting
    let trackVC = TrackingViewController(permissionRouting.viewController) {
    } viewDidDisappear: { [weak self] _ in
      self?.permissionRouting = nil
    }
    await viewController.present(viewController: trackVC, animated: animated)
  }

  public var viewController: UIViewController {
    navigationController
  }

  private var completionHandler: () -> Void = {}
  private let rootViewController: UIViewController
  private let navigationController: UINavigationController
  private let deviceCameraRoutingFactory: Factory<DeviceCameraRouting>
  private let deviceMicrophoneRoutingFactory: Factory<DeviceMicrophoneRouting>
  private let permissionRoutingFactory: Factory<PermissionRouting>
}
