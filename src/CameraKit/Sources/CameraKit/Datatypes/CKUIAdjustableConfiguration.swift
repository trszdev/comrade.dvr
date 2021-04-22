public struct CKUIAdjustableConfiguration: CKConfigurationKind, Hashable {
  public let cameras: [CKDeviceID: CKDevice<CKUIAdjustableCameraConfiguration>]
  public let microphone: CKDevice<CKUIAdjustableMicrophoneConfiguration>?
  public let isMulticamAvailable: Bool
}

public extension CKAdjustableConfiguration {
  var ui: CKUIAdjustableConfiguration {
    let uiCameras = cameras.mapValues { CKDevice(id: $0.id, configuration: $0.configuration.ui) }
    return CKUIAdjustableConfiguration(
      cameras: uiCameras,
      microphone: microphone.flatMap { CKDevice(id: $0.id, configuration: $0.configuration.ui) },
      isMulticamAvailable: uiCameras.values.allSatisfy(\.configuration.isMulticamAvailable)
    )
  }
}
