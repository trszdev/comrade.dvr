import AutocontainerKit

struct SessionAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.singleton.autoregister(SessionStarter.self, construct: SessionStarterImpl.init)
  }
}