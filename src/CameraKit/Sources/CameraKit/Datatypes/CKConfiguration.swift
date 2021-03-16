public struct CKConfiguration: Hashable {
  public let cameras: [CKDeviceID: CKDevice<CKCameraConfiguration>]
  public let microphone: CKDevice<CKMicrophoneConfiguration>?

  public init(
    cameras: [CKDeviceID: CKDevice<CKCameraConfiguration>],
    microphone: CKDevice<CKMicrophoneConfiguration>?
  ) {
    self.cameras = cameras
    self.microphone = microphone
  }

  public func with(cameras: [CKDeviceID: CKDevice<CKCameraConfiguration>]) -> CKConfiguration {
    CKConfiguration(cameras: cameras, microphone: microphone)
  }

  public func with(microphone: CKDevice<CKMicrophoneConfiguration>?) -> CKConfiguration {
    CKConfiguration(cameras: cameras, microphone: microphone)
  }
}
