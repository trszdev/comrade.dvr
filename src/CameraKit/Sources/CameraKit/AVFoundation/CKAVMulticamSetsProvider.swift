import AVFoundation

protocol CKAVMulticamSetsProvider {
  var multicamSets: [Set<CKDevice<[CKAdjustableCameraConfiguration]>>] { get }
}

final class CKAVMulticamSetsProviderImpl: CKAVMulticamSetsProvider {
  init(mapper: CKAVConfigurationMapper, discovery: CKAVDiscovery) {
    self.mapper = mapper
    self.discovery = discovery
  }

  let mapper: CKAVConfigurationMapper
  let discovery: CKAVDiscovery

  private(set) lazy var multicamSets: [Set<CKDevice<[CKAdjustableCameraConfiguration]>>] = {
    let discoveredSets = discovery.multiCameraDeviceSets
    return discoveredSets.compactMap(wrap(multicamSet:))
  }()

  private func wrap(multicamSet: Set<AVCaptureDevice>) -> Set<CKDevice<[CKAdjustableCameraConfiguration]>>? {
    var result = Set<CKDevice<[CKAdjustableCameraConfiguration]>>()
    for avCamera in multicamSet {
      guard let camera = mapper.camera(avCamera) else { return nil }
      let filteredConfiguration = camera.configuration.filter(\.isMulticamAvailable)
      guard !filteredConfiguration.isEmpty else { return nil }
      let filteredCamera = CKDevice(id: camera.id, configuration: filteredConfiguration)
      result.insert(filteredCamera)
    }
    return result
  }
}
