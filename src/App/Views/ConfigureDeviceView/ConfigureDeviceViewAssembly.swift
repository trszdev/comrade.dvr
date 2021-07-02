import AutocontainerKit

struct ConfigureDeviceViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.transient.autoregister(construct: ConfigureCameraViewBuilder.init)
    container.transient.autoregister(construct: ConfigureCameraBitrateCellViewBuilder.init)
    container.transient.autoregister(construct: ConfigureMicrophoneViewBuilder.init)
  }
}
