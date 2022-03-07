import SPPermissions
import SPPermissionsCamera
import SPPermissionsMicrophone
import SPPermissionsNotification
import Assets

final class DataSource: SPPermissionsDataSource {
  var language: Language?

  func configure(_ cell: SPPermissionsTableViewCell, for permission: SPPermissions.Permission) {
    switch permission {
    case .microphone:
      cell.permissionTitleLabel.text = language.string(.microphone)
      cell.permissionDescriptionLabel.text = language.string(.permissionsMicrophone)
    case .camera:
      cell.permissionTitleLabel.text = language.string(.camera)
      cell.permissionDescriptionLabel.text = language.string(.permissionsCamera)
    case .notification:
      cell.permissionTitleLabel.text = language.string(.notifications)
      cell.permissionDescriptionLabel.text = language.string(.permissionsNotifications)
    default:
      break
    }
    cell.permissionButton.allowTitle = language.string(.permissionsBtnAllow)
    cell.permissionButton.deniedTitle = language.string(.permissionsBtnDenied)
    cell.permissionButton.allowedTitle = language.string(.permissionsBtnAllowed)
  }

  func deniedAlertTexts(for permission: SPPermissions.Permission) -> SPPermissionsDeniedAlertTexts? {
    let texts = SPPermissionsDeniedAlertTexts()
    texts.titleText = language.string(.permissionsDenied)
    texts.descriptionText = language.string(.permissionsDeniedDescription)
    texts.actionText = language.string(.settings)
    texts.cancelText = language.string(.cancel)
    return texts
  }
}
