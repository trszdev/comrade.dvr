import AutocontainerKit

struct CoreDataAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.singleton.autoregister(CoreDataController.self, construct: CoreDataControllerImpl.init)
    container.transient.autoregister(SessionOutputSaver.self, construct: CKMediaChunkRepositoryImpl.init)
    container.transient.autoregister(CKMediaChunkRepository.self, construct: CKMediaChunkRepositoryImpl.init)
  }
}
