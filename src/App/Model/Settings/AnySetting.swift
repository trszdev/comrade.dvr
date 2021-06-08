import Combine

struct AnySetting<Value: SettingValue>: Setting {
  init<CustomSetting: Setting>(_ setting: CustomSetting) where CustomSetting.Value == Value {
    valueGetter = { setting.value }
    publisherGetter = { setting.publisher }
    update = setting.update(newValue:)
  }

  var value: Value { valueGetter() }
  var publisher: AnyPublisher<Value, Never> { publisherGetter() }
  func update(newValue: Value) throws {
    try update(newValue)
  }

  private let valueGetter: () -> Value
  private let publisherGetter: () -> AnyPublisher<Value, Never>
  private let update: (_ newValue: Value) throws -> Void
}
