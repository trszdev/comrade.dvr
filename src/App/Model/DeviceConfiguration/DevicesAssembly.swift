import AutocontainerKit

struct DevicesAssembly: AKAssembly {
  let isPreview: Bool

  func assemble(container: AKContainer) {
    if isPreview {
      container.transient.autoregister(DevicesStore.self, construct: TempDevicesStore.init)
    } else {

    }
    container.transient.autoregister(DevicesModel.self, construct: DevicesModelImpl.init(devicesStore:))
  }
}
