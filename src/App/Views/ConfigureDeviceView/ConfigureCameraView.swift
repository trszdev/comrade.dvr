import SwiftUI

struct ConfigureCameraView: View {
  let tablePickerCellViewBuilder: TablePickerCellViewBuilder
  let tableSliderCellViewBuilder: TableSliderCellViewBuilder

  var body: some View {
    TableView(sections: [
      [
        TableSwitchCellView(isOn: $isEnabled, sfSymbol: .checkmark, text: "Enabled").eraseToAnyView(),
      ],
      [
        tablePickerCellViewBuilder.makeView(
          selected: $size,
          title: { _ in "Resolution" },
          rightText: { _, value in value },
          sfSymbol: .photo,
          availableOptions: ["1920x1080", "1920x1080", "1920x1080"],
          isDisabled: !isEnabled
        )
        .eraseToAnyView(),
        tablePickerCellViewBuilder.makeView(
          selected: $fps,
          title: { _ in "FPS" },
          rightText: { _, value in value },
          sfSymbol: .camera,
          availableOptions: ["60FPS", "30FPS", "90FPS"],
          isDisabled: !isEnabled
        )
        .eraseToAnyView(),
        tablePickerCellViewBuilder.makeView(
          selected: $quality,
          title: { _ in "Video quality" },
          rightText: { _, value in value },
          sfSymbol: .eye,
          availableOptions: ["min", "low", "medium", "high", "max"],
          isDisabled: !isEnabled
        )
        .eraseToAnyView(),
        TableSwitchCellView(
          isOn: $useH265,
          sfSymbol: .video,
          text: "H.265 Codec",
          isDisabled: !isEnabled
        )
        .eraseToAnyView(),
        tableSliderCellViewBuilder.makeView(
          selected: $bitrateKbits,
          title: { _ in "Bitrate" },
          rightText: { _, value in "\(value)Kbit/s" },
          sfSymbol: .speedometer,
          range: 0.1...100,
          isDisabled: !isEnabled
        )
        .eraseToAnyView(),
      ],
      [
        tablePickerCellViewBuilder.makeView(
          selected: $zoom,
          title: { _ in "Zoom" },
          rightText: { _, value in value },
          sfSymbol: .zoom,
          availableOptions: ["1x", "1.5x", "2x"],
          isDisabled: !isEnabled
        )
        .eraseToAnyView(),
        tablePickerCellViewBuilder.makeView(
          selected: $fov,
          title: { _ in "Field of view" },
          rightText: { _, value in value },
          sfSymbol: .fov,
          availableOptions: ["45deg", "50deg", "90deg"],
          isDisabled: !isEnabled
        )
        .eraseToAnyView(),
        tablePickerCellViewBuilder.makeView(
          selected: $autofocus,
          title: { _ in "Autofocus" },
          rightText: { _, value in value },
          sfSymbol: .hare,
          availableOptions: ["None", "Contrast", "Phase"],
          isDisabled: !isEnabled
        )
        .eraseToAnyView(),
      ],
    ])
  }

  @State private var size = "1920x1080"
  @State private var zoom = "1x"
  @State private var fps = "60FPS"
  @State private var fov = "45deg"
  @State private var autofocus = "Contrast"
  @State private var quality = "min"
  @State private var useH265 = true
  @State private var bitrateKbits = 1.0
  @State private var isEnabled = true
}

#if DEBUG

struct ConfigureCameraViewPreview: PreviewProvider {
  static var previews: some View {
    locator.resolve(ConfigureCameraView.self)
  }
}

#endif
