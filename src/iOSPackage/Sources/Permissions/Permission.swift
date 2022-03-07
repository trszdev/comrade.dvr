import SPPermissions
import SPPermissionsCamera
import SPPermissionsMicrophone
import SPPermissionsNotification

public enum Permission {
  case camera
  case microphone
  case notification

  var spPermission: SPPermissions.Permission {
    switch self {
    case .camera:
      return .camera
    case .microphone:
      return .microphone
    case .notification:
      return .notification
    }
  }
}
