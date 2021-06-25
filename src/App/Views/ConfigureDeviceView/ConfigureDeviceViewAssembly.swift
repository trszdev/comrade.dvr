import AutocontainerKit

struct ConfigureDeviceViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.transient.autoregister(construct: ConfigureCameraViewBuilder.init(locator:))
    container.transient.autoregister(construct: ConfigureCameraBitrateCellViewBuilder.init(locator:))
    container.transient.autoregister(construct: ConfigureMicrophoneViewBuilder.init(tablePickerCellViewBuilder:))
  }
}
