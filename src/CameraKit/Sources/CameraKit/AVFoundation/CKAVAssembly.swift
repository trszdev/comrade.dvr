import AutocontainerKit
import AVFoundation

public struct CKAVAssembly: AKAssembly {
  public func assemble(container: AKContainer) {
    container.singleton.autoregister(CKTempFileMaker.self, construct: CKTempFileMakerImpl.init)
    container.transient.autoregister(CKTimestampMaker.self, construct: CKTimestampMakerImpl.init)
    container.singleton.autoregister(value: FileManager.default)
    container.singleton.autoregister(value: AVAudioSession.sharedInstance())
    container.transient.autoregister(construct: CKAVMicrophoneRecorderImpl.Builder.init)
    container.transient.autoregister(construct: CKAVMicrophoneSession.Builder.init)
    container.transient.autoregister(CKAVDiscovery.self, construct: CKAVDiscoveryImpl.init)
    container.transient.autoregister(CKAVConfigurationMapper.self, construct: CKAVConfigurationMapperImpl.init)
    container.transient.autoregister(construct: CKAVSessionMaker.Builder.init)
    container.transient.autoregister(CKMediaChunkMaker.self, construct: CKMediaChunkMakerImpl.init)
    container.transient.autoregister(CKAVCameraRecorderBuilder.self, construct: CKAVCameraRecorderBuilderImpl.init)
    container.transient.autoregister(construct: CKAVCameraSession.Builder.init)
    container.transient.autoregister(construct: CKAVNearestConfigurationPicker.Builder.init)
    container.transient.autoregister(construct: CKAVNearestMultiCameraConfigurationPicker.Builder.init)
    container.transient.autoregister(CKAVMulticamSetsProvider.self, construct: CKAVMulticamSetsProviderImpl.init)
    container.transient.autoregister(construct: CKAVConfigurationManager.Builder.init)
    container.transient.autoregister(CKManagerBuilder.self, construct: CKAVManager.Builder.init)
    container.transient.autoregister(construct: CKAVManager.Builder.init)
  }
}
