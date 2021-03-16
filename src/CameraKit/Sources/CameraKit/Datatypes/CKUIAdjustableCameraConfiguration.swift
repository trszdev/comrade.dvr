public struct CKUIAdjustableCameraConfiguration {
  public let sizes: [CKSize]
  public let minZoom: Double
  public let maxZoom: Double
  public let minFps: Int
  public let maxFps: Int
  public let minFieldOfView: Float
  public let maxFieldOfView: Float
  public let isVideoMirroringAvailable: Bool
  public let supportedStabilizationModes: [CKStabilizationMode]
  public let isMulticamAvailable: Bool
}

public extension Array where Element == CKAdjustableCameraConfiguration {
//  public let uiConfiguration: CKUIAdjustableCameraConfiguration {
//    CKUIAdjustableCameraConfiguration(
//    )
//  }
}
