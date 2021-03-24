public struct CKConfiguration: Hashable {
  public let cameras: [CKDeviceID: CKDevice<CKCameraConfiguration>]
  public let microphone: CKDevice<CKMicrophoneConfiguration>?

  public init(
    cameras: Set<CKDevice<CKCameraConfiguration>>,
    microphone: CKDevice<CKMicrophoneConfiguration>?
  ) {
    self.cameras = Dictionary(uniqueKeysWithValues: cameras.map { ($0.id, $0) })
    self.microphone = microphone
  }

  init(
    cameras: [CKDeviceID: CKDevice<CKCameraConfiguration>],
    microphone: CKDevice<CKMicrophoneConfiguration>?
  ) {
    self.cameras = cameras
    self.microphone = microphone
  }

  func with(cameras: [CKDeviceID: CKDevice<CKCameraConfiguration>]) -> CKConfiguration {
    CKConfiguration(cameras: cameras, microphone: microphone)
  }

  func with(microphone: CKDevice<CKMicrophoneConfiguration>?) -> CKConfiguration {
    CKConfiguration(cameras: cameras, microphone: microphone)
  }
}
