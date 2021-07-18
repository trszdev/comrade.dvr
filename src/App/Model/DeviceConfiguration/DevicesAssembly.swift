import AutocontainerKit
import CameraKit
import Foundation

struct DevicesAssembly: AKAssembly {
  let isPreview: Bool

  func assemble(container: AKContainer) {
    if isPreview {
      let tempDevicesStore = TempDevicesStore()
      container.singleton.autoregister(DevicesStore.self, value: tempDevicesStore)
    } else {
      container.singleton.autoregister(DevicesStore.self, construct: UserDefaultsDevicesStore.init)
    }
    container.singleton.autoregister(DevicesModel.self, construct: DevicesModelImpl.init)
  }
}
