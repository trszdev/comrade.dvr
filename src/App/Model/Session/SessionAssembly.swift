import AutocontainerKit
import CameraKit

struct SessionAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.singleton.autoregister(SessionController.self, construct: SessionControllerImpl.init)
    container.transient.autoregister(SessionMaker.self, construct: SessionMakerImpl.init)
    container.singleton.autoregister(SessionOutputSaver.self, construct: SessionOutputSaverImpl.init)
  }
}
