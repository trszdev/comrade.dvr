import AutocontainerKit

struct CoreDataAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.singleton.autoregister(CoreDataController.self, construct: CoreDataControllerImpl.init)
  }
}
