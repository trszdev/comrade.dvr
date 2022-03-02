import ComposableArchitecture
import Util
import Assets
import UIKit
import CommonUI

public struct SettingsState: Equatable {
  public init(isPremium: Bool = false, settings: Settings = .init()) {
    self.isPremium = isPremium
    self.settings = settings
  }

  public var isPremium: Bool = false
  @BindableState public var settings: Settings = .init()
}

public enum SettingsAction: BindableAction {
  case binding(BindingAction<SettingsState>)
  case clearAllRecordings
  case contactUs
  case upgradeToPro
  case settingsLoaded(Settings)
}

public struct SettingsEnvironment {
  public var repository: SettingsRepository = SettingsRepositoryStub()
  public var routing: Routing = RoutingStub()

  public init(repository: SettingsRepository = SettingsRepositoryStub(), routing: Routing = RoutingStub()) {
    self.repository = repository
    self.routing = routing
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
  default:
    break
  }
  return .none
}
.binding()
