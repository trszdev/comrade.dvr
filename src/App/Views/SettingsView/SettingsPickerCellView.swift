import SwiftUI

struct SettingsPickerCellViewBuilder<Value: SettingValue> {
  let viewModel: SettingsCellViewModelImpl<Value>
  let tablePickerCellViewBuilder: TablePickerCellViewBuilder

  func makeView(
    title: @escaping (AppLocale) -> String,
    rightText: @escaping (AppLocale, Value) -> String,
    sfSymbol: SFSymbol,
    availableOptions: [Value],
    separator: [Edge] = [.bottom],
    isDisabled: Bool = false
  ) -> AnyView {
    SettingsPickerCellView(
      viewModel: viewModel,
      tablePickerCellViewBuilder: tablePickerCellViewBuilder,
      title: title,
      rightText: rightText,
      sfSymbol: sfSymbol,
      availableOptions: availableOptions,
      separator: separator,
      isDisabled: isDisabled
    )
    .eraseToAnyView()
  }
}

struct SettingsPickerCellView<ViewModel: SettingsCellViewModel>: View {
  @Environment(\.appLocale) var appLocale: AppLocale
  @ObservedObject var viewModel: ViewModel
  let tablePickerCellViewBuilder: TablePickerCellViewBuilder
  let title: (AppLocale) -> String
  let rightText: (AppLocale, ViewModel.Value) -> String
  let sfSymbol: SFSymbol
  let availableOptions: [ViewModel.Value]
  let separator: [Edge]
  let isDisabled: Bool

  init(
    viewModel: ViewModel,
    tablePickerCellViewBuilder: TablePickerCellViewBuilder,
    title: @escaping (AppLocale) -> String,
    rightText: @escaping (AppLocale, ViewModel.Value) -> String,
    sfSymbol: SFSymbol,
    availableOptions: [ViewModel.Value],
    separator: [Edge],
    isDisabled: Bool
  ) {
    self._selected = State(initialValue: viewModel.value)
    self.tablePickerCellViewBuilder = tablePickerCellViewBuilder
    self.viewModel = viewModel
    self.title = title
    self.rightText = rightText
    self.sfSymbol = sfSymbol
    self.availableOptions = availableOptions
    self.separator = separator
    self.isDisabled = isDisabled
  }

  var body: some View {
    tablePickerCellViewBuilder.makeView(
      selected: $selected,
      title: title,
      rightText: rightText,
      sfSymbol: sfSymbol,
      availableOptions: availableOptions,
      separator: separator,
      isDisabled: isDisabled
    )
    .onChange(of: selected, perform: { value in
      viewModel.update(newValue: value)
    })
  }

  private func onSubmit() {
    viewModel.update(newValue: selected)
  }

  @State private var selected: ViewModel.Value
}
