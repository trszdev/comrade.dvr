public struct CKAdjustableConfiguration: CKConfigurationKind, Hashable {
  public let cameras: [CKDeviceID: CKDevice<[CKAdjustableCameraConfiguration]>]
  public let microphone: CKDevice<[CKAdjustableMicrophoneConfiguration]>?
}
