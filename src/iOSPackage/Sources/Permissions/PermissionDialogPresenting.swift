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

  func present() async -> Bool {
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

  nonisolated func didAllowPermission(_ permission: SPPermissions.Permission) {
    log.debug()
    Task { @MainActor in
      permissionCallback(true)
      permissionCallback = { _ in }
    }
  }

  nonisolated func didDeniedPermission(_ permission: SPPermissions.Permission) {
    log.debug()
    Task { @MainActor in
      permissionCallback(false)
      permissionCallback = { _ in }
    }
  }

  nonisolated func didHidePermissions(_ permissions: [SPPermissions.Permission]) {
    log.debug()
  }
}
