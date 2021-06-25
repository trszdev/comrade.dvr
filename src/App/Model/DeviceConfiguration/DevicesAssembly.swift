import AutocontainerKit
import CameraKit
import Foundation

struct DevicesAssembly: AKAssembly {
  let isPreview: Bool

  func assemble(container: AKContainer) {
    if isPreview {
      let tempDevicesStore = TempDevicesStore()
      container.singleton.autoregister(DevicesStore.self, value: tempDevicesStore)
      container.singleton.autoregister(
        CKNearestConfigurationPicker.self,
        value: ForcedConfigurationPicker(devices: tempDevicesStore.loadStoredDevices())
      )
    } else {
      container.singleton.autoregister(CKManager.self, value: CKAVManager.shared)
      container.singleton.autoregister(
        CKNearestConfigurationPicker.self,
        value: CKAVManager.shared.configurationPicker
      )
      container.singleton.autoregister(
        DevicesStore.self,
        construct: UserDefaultsDevicesStore.init(ckManager:userDefaults:)
      )
    }
    container.singleton.autoregister(value: UserDefaults.standard)
    container.singleton.autoregister(
      DevicesModel.self,
      construct: DevicesModelImpl.init(devicesStore:nearestConfigurationPicker:)
    )
  }
}
