public struct CKMicrophoneConfiguration: Identifiable, Hashable {
  public let id: CKDeviceConfigurationID

  public init(id: CKDeviceConfigurationID) {
    self.id = id
  }
}
