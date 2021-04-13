import AutocontainerKit
import AVFoundation

public struct CKAVAssembly: AKAssembly {
  public func assemble(container: AKContainer) {
    container.singleton.autoregister(CKTempFileMaker.self, construct: CKTempFileMakerImpl.init)
    container.transient.autoregister(CKTimestampMaker.self, construct: CKTimestampMakerImpl.init)
    container.singleton.autoregister(value: FileManager.default)
    container.singleton.autoregister(value: AVAudioSession.sharedInstance())
    container.transient.autoregister(
      CKAVMicrophoneRecorder.self,
      construct: CKAVMicrophoneRecorderImpl.init(mediaChunkMaker:)
    )
    container.transient.autoregister(construct: CKAVMicrophoneSession.Builder.init(mapper:session:recorder:))
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
    container.transient.autoregister(
      CKMediaChunkMaker.self,
      construct: CKMediaChunkMakerImpl.init(timestampMaker:tempFileMaker:)
    )
    container.transient.autoregister(
      CKAVCameraRecorder.self,
      construct: CKAVCameraRecorderImpl.init(mapper:mediaChunkMaker:)
    )
    container.transient.autoregister(construct: CKAVSingleCameraSession.Builder.init(mapper:recorder:))
  }
}
