import SwiftUI

protocol AppLocator {
  func makeMainView() -> AnyView

  associatedtype SettingsCellViewModelType: SettingsCellViewModel
  func settingsViewModel<Value>() -> SettingsCellViewModelType where SettingsCellViewModelType.Value == Value
}
