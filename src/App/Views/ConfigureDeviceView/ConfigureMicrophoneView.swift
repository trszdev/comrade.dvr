import SwiftUI

struct ConfigureMicrophoneView: View {
  let tablePickerCellViewBuilder: TablePickerCellViewBuilder

  var body: some View {
    TableView(sections: [
      [
        TableSwitchCellView(isOn: $isEnabled, sfSymbol: .checkmark, text: "Enabled").eraseToAnyView(),
      ],
      [
        tablePickerCellViewBuilder.makeView(
          selected: $polarPattern,
          title: { _ in "Polar pattern" },
          rightText: { _, value in value },
          sfSymbol: .polarPattern,
          availableOptions: ["unspecified", "cardioid", "stereo", "subcardioid", "omnidirectional"]
        )
        .eraseToAnyView(),
        tablePickerCellViewBuilder.makeView(
          selected: $quality,
          title: { _ in "Audio quality" },
          rightText: { _, value in value },
          sfSymbol: .ear,
          availableOptions: ["min", "low", "medium", "high", "max"]
        )
        .eraseToAnyView(),
      ],
    ])
  }

  @State private var isEnabled = true
  @State private var polarPattern = "unspecified"
  @State private var quality = "medium"
}

#if DEBUG

struct ConfigureMicrophoneViewPreview: PreviewProvider {
  static var previews: some View {
    locator.resolve(ConfigureMicrophoneView.self)
  }
}

#endif
