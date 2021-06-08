import SwiftUI

struct SettingsPickerCellViewBuilder<Value: SettingValue> {
  let viewModel: SettingsCellViewModelImpl<Value>
  let modalViewPresenter: ModalViewPresenter

  func makeView(
    title: @escaping (AppLocale) -> String,
    rightText: @escaping (AppLocale, Value) -> String,
    sfSymbol: SFSymbol,
    availableOptions: [Value]
  ) -> AnyView {
    SettingsPickerCellView(
      viewModel: viewModel,
      modalViewPresenter: modalViewPresenter,
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
  let modalViewPresenter: ModalViewPresenter
  let title: (AppLocale) -> String
  let rightText: (AppLocale, ViewModel.Value) -> String
  let sfSymbol: SFSymbol
  let availableOptions: [ViewModel.Value]

  init(
    viewModel: ViewModel,
    modalViewPresenter: ModalViewPresenter,
    title: @escaping (AppLocale) -> String,
    rightText: @escaping (AppLocale, ViewModel.Value) -> String,
    sfSymbol: SFSymbol,
    availableOptions: [ViewModel.Value]
  ) {
    self.viewModel = viewModel
    self.modalViewPresenter = modalViewPresenter
    self.title = title
    self.rightText = rightText
    self.sfSymbol = sfSymbol
    self.availableOptions = availableOptions
    self._selected = State(initialValue: viewModel.value)
  }

  var body: some View {
    SettingsCellView(
      text: title(appLocale),
      rightText: rightText(appLocale, viewModel.value),
      sfSymbol: sfSymbol,
      onTap: {
        modalViewPresenter.presentView { modalView() }
      }
    )
  }

  fileprivate func modalView(isVisible: Bool = false) -> some View {
    ModalView(isVisible: isVisible, onSubmit: onSubmit) {
      VStack(spacing: 0) {
        Text(title(appLocale))
        Picker(title(appLocale), selection: $selected) {
          ForEach(availableOptions, id: \.self) { availableOption in
            Text(rightText(appLocale, availableOption)).tag(availableOption)
          }
        }
        .frame(height: 180)
        .clipped()
      }
      .padding(.top, 18)
      .padding(.horizontal, 10)
    }
  }

  private func onSubmit() {
    viewModel.update(newValue: selected)
  }

  @State private var selected: ViewModel.Value
}

#if DEBUG

struct SettingsPickerCellViewPreview: PreviewProvider {
  static var previews: some View {
    let builder = locator.resolve(SettingsPickerCellViewBuilder<ThemeSetting>.self)!
    let cellView = SettingsPickerCellView(
      viewModel: builder.viewModel,
      modalViewPresenter: builder.modalViewPresenter,
      title: { $0.themeString },
      rightText: { $0.themeName($1) },
      sfSymbol: .theme,
      availableOptions: ThemeSetting.allCases
    )
    return VStack {
      cellView
      cellView.modalView(isVisible: true)
    }
    .padding()
    .background(Color.gray)
  }
}

#endif
