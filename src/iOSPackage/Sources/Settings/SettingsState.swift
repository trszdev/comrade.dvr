import ComposableArchitecture
import Util
import Assets
import UIKit

public struct SettingsState: Equatable {
  public init(settings: Settings = .init()) {
    self.settings = settings
  }

  @BindableState public var settings: Settings = .init()
}

public enum SettingsAction: BindableAction {
  case binding(BindingAction<SettingsState>)
  case clearAllRecordings
  case contactUs
  case settingsLoaded(Settings)
}

public struct SettingsEnvironment {
  public var repository: SettingsRepository = SettingsRepositoryStub()

  public init(repository: SettingsRepository = SettingsRepositoryStub()) {
    self.repository = repository
  }
}

public let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment> { state, action, environment in
  switch action {
  case .contactUs:
    let application = UIApplication.shared
    guard let url = URL(string: "mailto:\(L10n.appEmail)"), application.canOpenURL(url) else {
      return .none
    }
    application.open(url, options: [:], completionHandler: nil)
  case .binding:
    return .task { [state] in
      await environment.repository.save(settings: state.settings)
    }
  case .settingsLoaded(let settings):
    state.settings = settings
  default:
    break
  }
  return .none
}
.binding()
