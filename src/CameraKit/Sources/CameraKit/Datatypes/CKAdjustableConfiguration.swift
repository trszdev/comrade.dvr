public struct CKAdjustableConfiguration: Hashable {
  public let cameras: [CKDeviceID: CKDevice<[CKAdjustableCameraConfiguration]>]
  public let microphone: CKDevice<CKAdjustableMicrophoneConfiguration>?
}
