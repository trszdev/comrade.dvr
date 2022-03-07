import SPPermissions
import SPPermissionsCamera
import SPPermissionsMicrophone
import SPPermissionsNotification

public final class PermissionChecker: Equatable {
  public static func == (lhs: PermissionChecker, rhs: PermissionChecker) -> Bool {
    lhs === rhs
  }

  public var authorized: (_ permission: Permission) -> Bool?

  public init(authorized: @escaping (_ permission: Permission) -> Bool?) {
    self.authorized = authorized
  }

  public static let live: PermissionChecker = .init { permission in
    switch permission {
    case .camera:
      return SPPermissions.Permission.camera.status.asBool
    case .microphone:
      return SPPermissions.Permission.microphone.status.asBool
    case .notification:
      return SPPermissions.Permission.notification.status.asBool
    }
  }
}

private extension SPPermissions.PermissionStatus {
  var asBool: Bool? {
    switch self {
    case .authorized:
      return true
    case .denied:
      return false
    case .notDetermined:
      return nil
    case .notSupported:
      return false
    }
  }
}
