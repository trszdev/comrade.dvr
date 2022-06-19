import SPPermissions
import UIKit
import Util
import CommonUI

public protocol PermissionDialogPresenting {
  func tryPresentDialog(for permission: Permission) async -> Bool
}

public struct PermissionDialogPresentingStub: PermissionDialogPresenting {
  public init() {}

  public func tryPresentDialog(for permission: Permission) async -> Bool {
    false
  }
}

struct PermissionDialogPresenter: PermissionDialogPresenting {
  var checker: PermissionChecker

  func tryPresentDialog(for permission: Permission) async -> Bool {
    let status = checker.authorized(permission)
    if status == true {
      return true
    }
    let dialogCoordinator = await DialogCoordinator(permission.spPermission)
    return await dialogCoordinator.present()
  }
}

@MainActor private final class DialogCoordinator: SPPermissionsDelegate {
  init(_ permission: SPPermissions.Permission) {
    controller = SPPermissions.native([permission])
    controller.delegate = self
    controller.dataSource = dataSource
  }

  private let controller: SPPermissionsNativeController
  private let dataSource = DataSource()

  @MainActor func present() async -> Bool {
    guard let viewController = UIApplication.shared.topViewController else {
      return false
    }
    return await withCheckedContinuation { [weak self] continuation in
      self?.permissionCallback = {
        continuation.resume(returning: $0)
      }
      self?.controller.present(on: viewController)
    }
  }

  private var permissionCallback: (Bool) -> Void = { _ in }

  func didAllowPermission(_ permission: SPPermissions.Permission) {
    log.debug()
    permissionCallback(true)
    permissionCallback = { _ in }
  }

  func didDeniedPermission(_ permission: SPPermissions.Permission) {
    log.debug()
    permissionCallback(false)
    permissionCallback = { _ in }
  }

  func didHidePermissions(_ permissions: [SPPermissions.Permission]) {
    log.debug()
  }
}
