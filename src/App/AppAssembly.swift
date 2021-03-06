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
    container.singleton.autoregister(value: Calendar.current)
    container.singleton.autoregister(value: UserDefaults.standard)
    container.singleton.autoregister(value: UIApplication.shared)
  }

  var locator: AKLocator {
    let result = mockContainer
    result.transient.autoregister(CKMediaURLMaker.self, construct: SessionMediaURLMaker.init)
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
    CKAVAssembly(),
  ]

  private let previewAssemblies: [AKAssembly]  = [
    PreviewSettingsAssembly(),
    HistoryViewAssembly(isPreview: true),
    DevicesAssembly(isPreview: true),
    CoreDataAssembly(isPreview: true),
    SessionAssembly(isPreview: true),
  ]

  private let releaseAssemblies: [AKAssembly]  = [
    SettingsAssembly(),
    HistoryViewAssembly(isPreview: false),
    DevicesAssembly(isPreview: false),
    CoreDataAssembly(isPreview: false),
    SessionAssembly(isPreview: false),
  ]
}
