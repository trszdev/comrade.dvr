import ComposableArchitecture
import Util
import Assets
import UIKit

public struct SettingsState: Equatable {
  public enum Orientation: CaseIterable {
    case portrait
    case landscape
  }

  public init() {
  }

  @BindableState public var totalFileSize: FileSize? = .gigabytes(5)
  @BindableState public var maxFileLength: TimeInterval = .minutes(1)
  @BindableState public var orientation: Orientation?
  @BindableState public var language: Language?
  @BindableState public var appearance: Appearance?
  @BindableState public var autoStart: Bool = false
}

public enum SettingsAction: BindableAction {
  case binding(BindingAction<SettingsState>)
  case clearAllRecordings
  case contactUs
}

public struct SettingsEnvironment {

}

public let settingsReducer = Reducer<SettingsState, SettingsAction, Void> { _, action, _ in
  switch action {
  case .contactUs:
    let application = UIApplication.shared
    guard let url = URL(string: "mailto:\(L10n.appEmail)"), application.canOpenURL(url) else {
      return .none
    }
    application.open(url, options: [:], completionHandler: nil)
  default:
    break
  }
  return .none
}
.binding()
