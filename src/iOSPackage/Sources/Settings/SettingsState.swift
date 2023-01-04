import ComposableArchitecture
import Util
import Assets
import UIKit
import CommonUI
import Permissions

public struct SettingsState: Equatable {
  public struct LocalState: Equatable {
    public init(notificationsEnabled: Bool? = nil) {
      self.notificationsEnabled = notificationsEnabled
    }

    public var notificationsEnabled: Bool?
  }

  public init(localState: LocalState = .init(), isPremium: Bool = false, settings: Settings = .init()) {
    self.localState = localState
    self.isPremium = isPremium
    self.settings = settings
  }

  public var localState: LocalState = .init()
  public var isPremium: Bool = false
  @BindableState public var settings: Settings = .init()
}

public enum SettingsAction: BindableAction {
  case updatePermissionStatus
  case binding(BindingAction<SettingsState>)
  case clearAllRecordings
  case contactUs
  case upgradeToPro
  case openNotificationSettings
  case settingsLoaded(Settings)
}

public struct SettingsEnvironment {
  public var repository: SettingsRepository = SettingsRepositoryStub()
  public var routing: Routing = RoutingStub()
  public var permissionDialogPresenting: PermissionDialogPresenting = PermissionDialogPresentingStub()
  public var permissionChecker: PermissionChecker = .live

  public init(
    repository: SettingsRepository = SettingsRepositoryStub(),
    routing: Routing = RoutingStub(),
    permissionDialogPresenting: PermissionDialogPresenting = PermissionDialogPresentingStub(),
    permissionChecker: PermissionChecker = .live
  ) {
    self.repository = repository
    self.routing = routing
    self.permissionDialogPresenting = permissionDialogPresenting
    self.permissionChecker = permissionChecker
  }
}

public let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment> { state, action, environment in
  switch action {
  case .contactUs:
    let application = UIApplication.shared
    guard let url = URL(string: "mailto:\(Optional(Language.en).appEmail)"), application.canOpenURL(url) else {
      return .none
    }
    application.open(url, options: [:], completionHandler: nil)
  case .binding:
    return .task { [state] in
      await environment.repository.save(settings: state.settings)
    }
  case .settingsLoaded(let settings):
    state.settings = settings
  case .upgradeToPro:
    return .task {
      await environment.routing.showPaywall(animated: true)
    }
  case .updatePermissionStatus:
    state.localState.notificationsEnabled = environment.permissionChecker.authorized(.notification)
  case .openNotificationSettings:
    return .task {
      _ = await environment.permissionDialogPresenting.tryPresentDialog(for: .notification)
    }
  default:
    break
  }
  return .none
}
.binding()
