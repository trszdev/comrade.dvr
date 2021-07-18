import AutocontainerKit

struct CoreDataAssembly: AKAssembly {
  let isPreview: Bool

  func assemble(container: AKContainer) {
    if isPreview {
      container.transient.autoregister(SessionOutputSaver.self, construct: PreviewMediaChunkRepository.init)
      container.transient.autoregister(MediaChunkRepository.self, construct: PreviewMediaChunkRepository.init)
    } else {
      container.singleton.autoregister(CoreDataController.self, construct: CoreDataControllerImpl.init)
      container.transient.autoregister(SessionOutputSaver.self) { (locator: AKLocator) in
        locator.resolve(MediaChunkRepository.self)
      }
      container.singleton.autoregister(MediaChunkRepository.self, construct: MediaChunkRepositoryImpl.init)
    }
  }
}
