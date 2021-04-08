public struct CKAVCamera {
  public let value: CKDeviceID
  public static let back = CKAVCamera(value: CKDeviceID(value: "back-camera"))
  public static let front = CKAVCamera(value: CKDeviceID(value: "front-camera"))
}

public extension CKConfigurationKind {
  func camera(_ id: CKAVCamera) -> CKDevice<CameraConfiguration>? {
    cameras[id.value]
  }
}
