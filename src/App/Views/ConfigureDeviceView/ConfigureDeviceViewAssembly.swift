import AutocontainerKit

struct ConfigureDeviceViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.transient.autoregister(
      construct: ConfigureCameraViewBuilder.init(
        tablePickerCellViewBuilder:
        tableSliderCellViewBuilder:
        configureCameraBitrateCellViewBuilder:
      )
    )
    container.transient.autoregister(construct: ConfigureCameraBitrateCellViewBuilder.init(modalViewPresenter:))
    container.transient.autoregister(construct: ConfigureMicrophoneViewBuilder.init(tablePickerCellViewBuilder:))
  }
}
