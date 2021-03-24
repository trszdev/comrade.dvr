import AutocontainerKit

public struct CKAVAssembly: AKAssembly {
  public func assemble(container: AKContainer) {
    container.transient.autoregister(construct: CKAVManager.Builder.init(locator:))
    container.transient.autoregister(CKAVDiscovery.self, construct: CKAVDiscoveryImpl.init)
    container.transient.autoregister(
      CKAVConfigurationMapper.self,
      construct: CKAVConfigurationMapperImpl.init(discovery:)
    )
    container.transient.autoregister(
      CKSessionMaker.self,
      construct: CKAVSessionMaker.init(configurationMapper:locator:)
    )
    container.transient.autoregister(construct: CKAVSingleCameraSession.Builder.init(mapper:))
  }
}
