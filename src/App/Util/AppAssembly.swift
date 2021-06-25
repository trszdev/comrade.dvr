import AutocontainerKit
import SwiftUI

struct AppAssembly: AKAssembly {
  var isPreview = false

  func assemble(container: AKContainer) {
    if isPreview {
      container.registerMany(assemblies: previewAssemblies)
    } else {
      container.registerMany(assemblies: releaseAssemblies)
    }
    container.registerMany(assemblies: commonAssemblies)
  }

  private let commonAssemblies: [AKAssembly] = [
    SettingsViewAssembly(),
    MainViewAssembly(),
    UtilAssembly(),
    RootViewAssembly(),
    TableViewAssembly(),
    ConfigureDeviceViewAssembly(),
    StartViewAssembly(),
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
