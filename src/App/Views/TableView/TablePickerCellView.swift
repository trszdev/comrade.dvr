import SwiftUI
import Combine
import AutocontainerKit

struct TablePickerCellViewBuilder {
  let locator: AKLocator

  func makeView<Value: Hashable>(
    selected: Binding<Value>,
    title: @escaping (AppLocale) -> String,
    rightText: @escaping (AppLocale, Value) -> String,
    sfSymbol: SFSymbol,
    availableOptions: [Value],
    separator: [Edge] = [Edge.bottom],
    isDisabled: Bool = false
  ) -> TablePickerCellView<Value> {
    TablePickerCellView(
      selected: selected,
      modalViewPresenter: locator.resolve(ModalViewPresenter.self),
      title: title,
      rightText: rightText,
      sfSymbol: sfSymbol,
      availableOptions: availableOptions,
      separator: separator,
      isDisabled: isDisabled
    )
  }
}

struct TablePickerCellView<Value: Hashable>: View {
  init(
    selected: Binding<Value>,
    modalViewPresenter: ModalViewPresenter,
    title: @escaping (AppLocale) -> String,
    rightText: @escaping (AppLocale, Value) -> String,
    sfSymbol: SFSymbol,
    availableOptions: [Value],
    separator: [Edge] = [Edge.bottom],
    isDisabled: Bool = false
  ) {
    self._selected = selected
    self._modalSelected = State(initialValue: selected.wrappedValue)
    self.modalViewPresenter = modalViewPresenter
    self.title = title
    self.rightText = rightText
    self.sfSymbol = sfSymbol
    self.availableOptions = availableOptions
    self.separator = separator
    self.isDisabled = isDisabled
  }

  @Environment(\.theme) var theme: Theme
  @Environment(\.appLocale) var appLocale: AppLocale
  @Binding var selected: Value
  let modalViewPresenter: ModalViewPresenter
  let title: (AppLocale) -> String
  let rightText: (AppLocale, Value) -> String
  let sfSymbol: SFSymbol
  let availableOptions: [Value]
  var separator = [Edge.bottom]
  var isDisabled = false

  var body: some View {
    TableCellView(
      centerView: Text(title(appLocale)).eraseToAnyView(),
      rightView: Text(rightText(appLocale, selected)).eraseToAnyView(),
      sfSymbol: sfSymbol,
      separator: separator,
      isDisabled: isDisabled
    )
    .onTapGesture {
      modalViewPresenter.presentView(content: modalContentView)
    }
    .onReceive(modalViewPresenter.submitPublisher, perform: onSubmit)
  }

  fileprivate func modalContentView() -> AnyView {
    VStack(spacing: 0) {
      Text(title(appLocale))
      Picker(title(appLocale), selection: $modalSelected) {
        ForEach(availableOptions, id: \.self) { availableOption in
          Text(rightText(appLocale, availableOption)).tag(availableOption)
        }
      }
      .pickerStyle(.wheel)
      .frame(height: 180)
      .clipped()
    }
    .padding(.top, 18)
    .padding(.horizontal, 10)
    .eraseToAnyView()
  }

  private func onSubmit() {
    selected = modalSelected
  }

  @State private var modalSelected: Value
}

#if DEBUG

struct TablePickerCellViewPreview: PreviewProvider {
  static var previews: some View {
    let view = locator.resolve(TablePickerCellViewBuilder.self).makeView(
      selected: .constant(true),
      title: { $0.fullAppName },
      rightText: { $0.languageName($1 ? .english : .russian) },
      sfSymbol: .language,
      availableOptions: [true, false]
    )
    VStack {
      view
      view.environment(\.theme, DarkTheme())
      ModalView(isVisible: true, content: view.modalContentView)
      ModalView(isVisible: true, content: view.modalContentView).colorScheme(.dark)
    }
    .padding()
    .background(Color.gray)
  }
}

#endif
