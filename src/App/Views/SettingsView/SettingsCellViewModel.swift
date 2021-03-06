import SwiftUI
import Combine

protocol SettingsCellViewModel: ObservableObject {
  associatedtype Value: SettingValue
  var value: Value { get }
  var valuePublished: Published<Value> { get }
  var valuePublisher: Published<Value>.Publisher { get }
  func update(newValue: Value)
}

final class SettingsCellViewModelImpl<Value: SettingValue>: SettingsCellViewModel {
  init(setting: AnySetting<Value>) {
    self.setting = setting
    self.value = setting.value
    self.cancellable = setting.publisher.assignWeak(to: \.value, on: self)
  }

  @Published var value: Value
  var valuePublished: Published<Value> { _value }
  var valuePublisher: Published<Value>.Publisher { $value }

  func update(newValue: Value) {
    try? setting.update(newValue: newValue)
  }

  private let setting: AnySetting<Value>
  private var cancellable: AnyCancellable?
}
