import SwiftUI
import Combine
import AutocontainerKit

struct TableSliderCellViewBuilder {
  let locator: AKLocator

  func makeView<Value: BinaryFloatingPoint>(
    selected: Binding<Value>,
    title: @escaping (AppLocale) -> String,
    rightText: @escaping (AppLocale, Value) -> String,
    sfSymbol: SFSymbol,
    range: ClosedRange<Value>,
    separator: [Edge] = [Edge.bottom],
    isDisabled: Bool = false
  ) -> TableSliderCellView<Value> where Value.Stride: BinaryFloatingPoint {
    TableSliderCellView(
      selected: selected,
      modalViewPresenter: locator.resolve(ModalViewPresenter.self),
      title: title,
      rightText: rightText,
      sfSymbol: sfSymbol,
      range: range,
      separator: separator,
      isDisabled: isDisabled
    )
  }
}

struct TableSliderCellView<Value: BinaryFloatingPoint>: View where Value.Stride: BinaryFloatingPoint {
  init(
    selected: Binding<Value>,
    modalViewPresenter: ModalViewPresenter,
    title: @escaping (AppLocale) -> String,
    rightText: @escaping (AppLocale, Value) -> String,
    sfSymbol: SFSymbol,
    range: ClosedRange<Value>,
    separator: [Edge] = [Edge.bottom],
    isDisabled: Bool = false
  ) {
    self._selected = selected
    self._modalSelected = StateObject(wrappedValue: ObservableValue(selected.wrappedValue))
    self.modalViewPresenter = modalViewPresenter
    self.title = title
    self.rightText = rightText
    self.sfSymbol = sfSymbol
    self.range = range
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
  let range: ClosedRange<Value>
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
    .onReceive(modalSelected.objectWillChange, perform: modalViewPresenter.updateModal)
  }

  func modalContentView() -> AnyView {
    VStack(spacing: 0) {
      Text(title(appLocale))
      Text(rightText(appLocale, modalSelected.value)).padding(.top, 18)
      Slider(value: $modalSelected.value, in: range).padding(.vertical, 10)
    }
    .padding(.top, 18)
    .padding(.horizontal, 10)
    .eraseToAnyView()
  }

  private func onSubmit() {
    selected = modalSelected.value
  }

  @StateObject private var modalSelected: ObservableValue<Value>
}

#if DEBUG

struct TableSliderCellViewPreview: PreviewProvider {
  static var previews: some View {
    let view = locator.resolve(TableSliderCellViewBuilder.self).makeView(
      selected: .constant(1.0),
      title: { $0.fullAppName },
      rightText: { _, value in "\(value)" },
      sfSymbol: .language,
      range: -1...2
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
