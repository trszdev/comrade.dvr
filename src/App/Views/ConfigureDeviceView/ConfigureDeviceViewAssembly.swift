import AutocontainerKit

struct ConfigureDeviceViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.transient.autoregister(
      construct: ConfigureCameraView.init(tablePickerCellViewBuilder:tableSliderCellViewBuilder:)
    )
    container.transient.autoregister(construct: ConfigureMicrophoneView.init(tablePickerCellViewBuilder:))
  }
}
