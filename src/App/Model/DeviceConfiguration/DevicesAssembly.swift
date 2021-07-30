import AutocontainerKit
import CameraKit
import Foundation

struct DevicesAssembly: AKAssembly {
  let isPreview: Bool

  func assemble(container: AKContainer) {
    container.singleton.autoregister(DevicesStore.self, construct: UserDefaultsDevicesStore.init)
    if isPreview {
      container.singleton.autoregister(DevicesModel.self, construct: PreviewDevicesModel.init)
    } else {
      container.singleton.autoregister(DevicesModel.self, construct: DevicesModelImpl.init)
    }
  }
}
