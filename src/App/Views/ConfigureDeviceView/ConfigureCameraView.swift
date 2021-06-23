import SwiftUI
import CameraKit

struct ConfigureCameraViewBuilder {
  let tablePickerCellViewBuilder: TablePickerCellViewBuilder
  let tableSliderCellViewBuilder: TableSliderCellViewBuilder
  let configureCameraBitrateCellViewBuilder: ConfigureCameraBitrateCellViewBuilder

  func makeView() -> AnyView {
    ConfigureCameraView(
      viewModel: ConfigureCameraViewModelImpl.sample,
      tablePickerCellViewBuilder: tablePickerCellViewBuilder,
      tableSliderCellViewBuilder: tableSliderCellViewBuilder,
      configureCameraBitrateCellViewBuilder: configureCameraBitrateCellViewBuilder
    )
    .eraseToAnyView()
  }
}

struct ConfigureCameraView<ViewModel: ConfigureCameraViewModel>: View {
  @Environment(\.appLocale) var appLocale: AppLocale
  @ObservedObject var viewModel: ViewModel
  let tablePickerCellViewBuilder: TablePickerCellViewBuilder
  let tableSliderCellViewBuilder: TableSliderCellViewBuilder
  let configureCameraBitrateCellViewBuilder: ConfigureCameraBitrateCellViewBuilder

  var body: some View {
    TableView(sections: [
      [
        TableSwitchCellView(
          isOn: Binding(get: { viewModel.isEnabled }, set: { viewModel.isEnabled = $0 }),
          sfSymbol: .checkmark,
          text: appLocale.deviceEnabledString
        )
        .eraseToAnyView(),
      ],
      [
        tablePickerCellViewBuilder.makeView(
          selected: Binding(get: { viewModel.resolution }, set: { viewModel.resolution = $0 }),
          title: { $0.resolutionString },
          rightText: { $0.size($1) },
          sfSymbol: .photo,
          availableOptions: viewModel.adjustableConfiguration.sizes.sorted { $0.scalar > $1.scalar },
          isDisabled: isDisabled
        )
        .eraseToAnyView(),
        tablePickerCellViewBuilder.makeView(
          selected: Binding(get: { viewModel.fps }, set: { viewModel.fps = $0 }),
          title: { $0.fpsString },
          rightText: { _, value in "\(value)FPS" },
          sfSymbol: .camera,
          availableOptions: viewModel.fpsRange,
          isDisabled: isDisabled
        )
        .eraseToAnyView(),
        tablePickerCellViewBuilder.makeView(
          selected: Binding(get: { viewModel.quality }, set: { viewModel.quality = $0 }),
          title: { $0.qualityString },
          rightText: { $0.quality($1) },
          sfSymbol: .eye,
          availableOptions: CKQuality.allCases,
          isDisabled: isDisabled
        )
        .eraseToAnyView(),
        TableSwitchCellView(
          isOn: Binding(get: { viewModel.useH265 }, set: { viewModel.useH265 = $0 }),
          sfSymbol: .video,
          text: appLocale.useH265String,
          isDisabled: isDisabled
        )
        .eraseToAnyView(),
        configureCameraBitrateCellViewBuilder.makeView(
          selected: Binding(get: { viewModel.bitrate }, set: { viewModel.bitrate = $0 }),
          resolution: viewModel.resolution,
          title: { $0.bitrateString },
          sfSymbol: .speedometer,
          isDisabled: isDisabled
        )
        .eraseToAnyView(),
      ],
      [
        tableSliderCellViewBuilder.makeView(
          selected: Binding(get: { viewModel.zoom }, set: { viewModel.zoom = $0 }),
          title: { $0.zoomString },
          rightText: { $0.zoom($1) },
          sfSymbol: .zoom,
          range: viewModel.zoomRange,
          isDisabled: isDisabled
        )
        .eraseToAnyView(),
        tablePickerCellViewBuilder.makeView(
          selected: Binding(get: { viewModel.fov }, set: { viewModel.fov = $0 }),
          title: { $0.fieldOfViewString },
          rightText: { _, value in "\(value)°" },
          sfSymbol: .fov,
          availableOptions: viewModel.fovRange,
          isDisabled: isDisabled
        )
        .eraseToAnyView(),
        tablePickerCellViewBuilder.makeView(
          selected: Binding(get: { viewModel.autofocus }, set: { viewModel.autofocus = $0 }),
          title: { $0.autofocusString },
          rightText: { $0.autofocus($1) },
          sfSymbol: .hare,
          availableOptions: CKAutoFocus.allCases,
          isDisabled: isDisabled
        )
        .eraseToAnyView(),
      ],
    ])
  }

  private var isDisabled: Bool {
    !viewModel.isEnabled
  }
}

private extension ConfigureCameraViewModel {
  var fovRange: [Int] {
    Array(adjustableConfiguration.minFieldOfView...adjustableConfiguration.maxFieldOfView)
  }

  var fpsRange: [Int] {
    Array(adjustableConfiguration.minFps...adjustableConfiguration.maxFps)
  }

  var zoomRange: ClosedRange<Double> {
    adjustableConfiguration.minZoom...adjustableConfiguration.maxZoom
  }
}

#if DEBUG

struct ConfigureCameraViewPreview: PreviewProvider {
  static var previews: some View {
    locator.resolve(ConfigureCameraViewBuilder.self).makeView()
  }
}

#endif
