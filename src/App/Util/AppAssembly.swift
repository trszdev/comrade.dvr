import AutocontainerKit
import SwiftUI
import CameraKit

struct AppAssembly: AKAssembly {
  var isPreview = false

  func assemble(container: AKContainer) {
    if isPreview {
      container.registerMany(assemblies: previewAssemblies)
    } else {
      container.registerMany(assemblies: releaseAssemblies)
    }
    container.registerMany(assemblies: commonAssemblies)
    container.singleton.autoregister(value: UserDefaults.standard)
    container.singleton.autoregister(value: UIApplication.shared)
  }

  var locator: AKLocator {
    let result = mockContainer
    result.transient.autoregister(CKMediaChunkMaker.self, construct: SessionMediaChunkMaker.init)
    return result
  }

  private let commonAssemblies: [AKAssembly] = [
    SettingsViewAssembly(),
    MainViewAssembly(),
    UtilAssembly(),
    RootViewAssembly(),
    TableViewAssembly(),
    ConfigureDeviceViewAssembly(),
    StartViewAssembly(),
    SessionViewAssembly(),
    SessionAssembly(),
    CKAVAssembly(),
  ]

  private let previewAssemblies: [AKAssembly]  = [
    PreviewSettingsAssembly(),
    DevicesAssembly(isPreview: true),
  ]

  private let releaseAssemblies: [AKAssembly]  = [
    SettingsAssembly(),
    DevicesAssembly(isPreview: false),
  ]
}
