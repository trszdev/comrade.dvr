public struct CKCameraConfiguration: Identifiable, Hashable {
  public let id: CKDeviceConfigurationID
  public let size: CKSize
  public let zoom: Double
  public let fps: Int
  public let fieldOfView: Float
  public let orientation: CKOrientation
  public let autoFocus: CKAutoFocus
  public let isVideoMirrored: Bool
  public let stabilizationMode: CKStabilizationMode
}
