import AutocontainerKit
import CameraKit

struct SessionAssembly: AKAssembly {
  let isPreview: Bool

  func assemble(container: AKContainer) {
    if isPreview {
      container.singleton.autoregister(SessionController.self, construct: PreviewSessionController.init)
    } else {
      container.singleton.autoregister(SessionController.self, construct: SessionControllerImpl.init)
    }
    container.transient.autoregister(SessionMaker.self, construct: SessionMakerImpl.init)
  }
}
