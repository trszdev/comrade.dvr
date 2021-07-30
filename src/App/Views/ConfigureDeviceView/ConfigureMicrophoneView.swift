import SwiftUI
import CameraKit

struct ConfigureMicrophoneViewBuilder {
  let tablePickerCellViewBuilder: TablePickerCellViewBuilder

  func makeView<ViewModel: ConfigureMicrophoneViewModel>(viewModel: ViewModel) -> AnyView {
    ConfigureMicrophoneView(
      viewModel: viewModel,
      tablePickerCellViewBuilder: tablePickerCellViewBuilder
    )
    .eraseToAnyView()
  }

  func makeView() -> AnyView {
    ConfigureMicrophoneView(
      viewModel: ConfigureMicrophoneViewModelImpl.sample,
      tablePickerCellViewBuilder: tablePickerCellViewBuilder
    )
    .eraseToAnyView()
  }
}

struct ConfigureMicrophoneView<ViewModel: ConfigureMicrophoneViewModel>: View {
  @Environment(\.appLocale) var appLocale: AppLocale
  @ObservedObject var viewModel: ViewModel
  let tablePickerCellViewBuilder: TablePickerCellViewBuilder

  var body: some View {
    TableView(sections: [
      [
        TableSwitchCellView(
          isOn: Binding(get: { viewModel.isEnabled }, set: { viewModel.isEnabled = $0 }),
          sfSymbol: .checkmark,
          text: appLocale.deviceEnabledString,
          separator: []
        )
        .eraseToAnyView(),
      ],
      [
        tablePickerCellViewBuilder.makeView(
          selected: Binding(get: { viewModel.location }, set: { viewModel.location = $0 }),
          title: { $0.deviceLocationString },
          rightText: { $0.deviceLocation($1) },
          sfSymbol: .deviceLocation,
          availableOptions: Array(viewModel.adjustableConfiguration.locations),
          isDisabled: isDisabled
        )
        .eraseToAnyView(),
        tablePickerCellViewBuilder.makeView(
          selected: Binding(get: { viewModel.polarPattern }, set: { viewModel.polarPattern = $0 }),
          title: { $0.polarPatternString },
          rightText: { $0.polarPattern($1) },
          sfSymbol: .polarPattern,
          availableOptions: Array(viewModel.adjustableConfiguration.polarPatterns),
          isDisabled: isDisabled
        )
        .eraseToAnyView(),
        tablePickerCellViewBuilder.makeView(
          selected: Binding(get: { viewModel.quality }, set: { viewModel.quality = $0 }),
          title: { $0.qualityString },
          rightText: { $0.quality($1) },
          sfSymbol: .ear,
          availableOptions: CKQuality.allCases,
          isDisabled: isDisabled
        )
        .eraseToAnyView(),
      ],
    ])
    .accessibility(.configureMicrophoneView)
  }

  private var isDisabled: Bool {
    !viewModel.isEnabled
  }
}

#if DEBUG

struct ConfigureMicrophoneViewPreview: PreviewProvider {
  static var previews: some View {
    locator.resolve(ConfigureMicrophoneViewBuilder.self).makeView()
  }
}

#endif
