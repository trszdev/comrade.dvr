import SwiftUI

struct SettingsPickerCellViewBuilder<Value: SettingValue> {
  let viewModel: SettingsCellViewModelImpl<Value>
  let tablePickerCellViewBuilder: TablePickerCellViewBuilder

  func makeView(
    title: @escaping (AppLocale) -> String,
    rightText: @escaping (AppLocale, Value) -> String,
    sfSymbol: SFSymbol,
    availableOptions: [Value]
  ) -> AnyView {
    SettingsPickerCellView(
      viewModel: viewModel,
      tablePickerCellViewBuilder: tablePickerCellViewBuilder,
      title: title,
      rightText: rightText,
      sfSymbol: sfSymbol,
      availableOptions: availableOptions
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

  init(
    viewModel: ViewModel,
    tablePickerCellViewBuilder: TablePickerCellViewBuilder,
    title: @escaping (AppLocale) -> String,
    rightText: @escaping (AppLocale, ViewModel.Value) -> String,
    sfSymbol: SFSymbol,
    availableOptions: [ViewModel.Value]
  ) {
    self._selected = State(initialValue: viewModel.value)
    self.tablePickerCellViewBuilder = tablePickerCellViewBuilder
    self.viewModel = viewModel
    self.title = title
    self.rightText = rightText
    self.sfSymbol = sfSymbol
    self.availableOptions = availableOptions
  }

  var body: some View {
    tablePickerCellViewBuilder.makeView(
      selected: $selected,
      title: title,
      rightText: rightText,
      sfSymbol: sfSymbol,
      availableOptions: availableOptions
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
