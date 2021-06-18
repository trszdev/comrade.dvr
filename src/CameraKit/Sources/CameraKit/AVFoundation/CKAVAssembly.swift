import AutocontainerKit
import AVFoundation

public struct CKAVAssembly: AKAssembly {
  public func assemble(container: AKContainer) {
    container.singleton.autoregister(CKTempFileMaker.self, construct: CKTempFileMakerImpl.init)
    container.transient.autoregister(CKTimestampMaker.self, construct: CKTimestampMakerImpl.init)
    container.singleton.autoregister(value: FileManager.default)
    container.singleton.autoregister(value: AVAudioSession.sharedInstance())
    container.transient.autoregister(construct: CKAVMicrophoneRecorderImpl.Builder.init(mediaChunkMaker:))
    container.transient.autoregister(construct: CKAVMicrophoneSession.Builder.init(mapper:session:locator:))
    container.transient.autoregister(CKAVDiscovery.self, construct: CKAVDiscoveryImpl.init)
    container.transient.autoregister(
      CKAVConfigurationMapper.self,
      construct: CKAVConfigurationMapperImpl.init(discovery:)
    )
    container.transient.autoregister(
      construct: CKAVSessionMaker.Builder.init(cameraSessionBuilder:microphoneSessionBuilder:)
    )
    container.transient.autoregister(
      CKMediaChunkMaker.self,
      construct: CKMediaChunkMakerImpl.init(timestampMaker:tempFileMaker:)
    )
    container.transient.autoregister(
      CKAVCameraRecorderBuilder.self,
      construct: CKAVCameraRecorderBuilderImpl.init(mapper:mediaChunkMaker:)
    )
    container.transient.autoregister(construct: CKAVCameraSession.Builder.init(mapper:recorderBuilder:))
    container.transient.autoregister(construct: CKAVNearestConfigurationPicker.Builder.init(multiCameraPickerBuilder:))
    container.transient.autoregister(
      construct: CKAVNearestMultiCameraConfigurationPicker.Builder.init(multicamSetsProvider:)
    )
    container.transient.autoregister(
      CKAVMulticamSetsProvider.self,
      construct: CKAVMulticamSetsProviderImpl.init(mapper:discovery:)
    )
    container.transient.autoregister(
      construct: CKAVConfigurationManager.Builder.init(configurationMapper:configurationPickerBuilder:)
    )
    container.transient.autoregister(
      CKManagerBuilder.self,
      construct: CKAVManager.Builder.init(configurationManagerBuilder:sessionMakerBuilder:)
    )
    container.transient.autoregister(
      construct: CKAVManager.Builder.init(configurationManagerBuilder:sessionMakerBuilder:)
    )
  }
}
