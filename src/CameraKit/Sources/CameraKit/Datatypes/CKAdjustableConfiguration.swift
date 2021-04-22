public struct CKAdjustableConfiguration: CKConfigurationKind, Hashable {
  public let cameras: [CKDeviceID: CKDevice<[CKAdjustableCameraConfiguration]>]
  public let microphone: CKDevice<[CKAdjustableMicrophoneConfiguration]>?

  static let empty = CKAdjustableConfiguration(cameras: [:], microphone: nil)
}
