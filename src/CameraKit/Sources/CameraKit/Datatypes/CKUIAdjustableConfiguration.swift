public struct CKUIAdjustableConfiguration: CKConfigurationKind, Hashable {
  public let cameras: [CKDeviceID: CKDevice<CKUIAdjustableCameraConfiguration>]
  public let microphone: CKDevice<CKUIAdjustableMicrophoneConfiguration>?
}

public extension CKAdjustableConfiguration {
  var ui: CKUIAdjustableConfiguration {
    CKUIAdjustableConfiguration(
      cameras: cameras.mapValues { CKDevice(id: $0.id, configuration: $0.configuration.ui) },
      microphone: microphone.flatMap { CKDevice(id: $0.id, configuration: $0.configuration.ui) }
    )
  }
}
