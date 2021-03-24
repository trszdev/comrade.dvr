public struct CKAdjustableCameraConfiguration: Identifiable, Hashable {
  public let id: CKDeviceConfigurationID
  public let size: CKSize
  public let minZoom: Double
  public let maxZoom: Double
  public let minFps: Int
  public let maxFps: Int
  public let fieldOfView: Double
  public let isVideoMirroringAvailable: Bool
  public let supportedStabilizationModes: [CKStabilizationMode]
  public let isMulticamAvailable: Bool
}
