import ComposableArchitecture
import Util

public struct SettingsState: Equatable {
  public enum Orientation {
    case portrait
    case landscape
  }

  public var totalFileSize: FileSize = .gigabytes(5)
  public var maxFileLength: TimeInterval = .minutes(1)
  public var orientation: Orientation?
  public var language: Language?
  public var appearance: Appearance?
}

public enum SettingsAction: BindableAction {
  case binding(BindingAction<SettingsState>)
}

public let settingsReducer = Reducer<SettingsState, SettingsAction, Void> { state, action, _ in
  switch action {
  default:
    break
  }
  return .none
}
