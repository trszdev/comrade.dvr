public struct CKUIAdjustableCameraConfiguration: Hashable {
  public let sizes: Set<CKSize>
  public let minZoom: Double
  public let maxZoom: Double
  public let minFps: Int
  public let maxFps: Int
  public let minFieldOfView: Double
  public let maxFieldOfView: Double
  public let isVideoMirroringAvailable: Bool
  public let supportedStabilizationModes: Set<CKStabilizationMode>
  public let isMulticamAvailable: Bool
}

public extension Array where Element == CKAdjustableCameraConfiguration {
  var ui: CKUIAdjustableCameraConfiguration {
    var sizes = Set<CKSize>()
    var minZoom = Double.greatestFiniteMagnitude
    var maxZoom = -Double.greatestFiniteMagnitude
    var minFps = Int.max
    var maxFps = Int.min
    var minFieldOfView = Double.greatestFiniteMagnitude
    var maxFieldOfView = -Double.greatestFiniteMagnitude
    var isVideoMirroringAvailable = false
    var isMulticamAvailable = false
    var supportedStabilizationModes = Set<CKStabilizationMode>()
    for conf in self {
      sizes.insert(conf.size)
      supportedStabilizationModes.formUnion(conf.supportedStabilizationModes)
      isVideoMirroringAvailable = conf.isVideoMirroringAvailable || isVideoMirroringAvailable
      isMulticamAvailable = conf.isMulticamAvailable || isMulticamAvailable
      minZoom = Swift.min(minZoom, conf.minZoom)
      maxZoom = Swift.max(maxZoom, conf.maxZoom)
      minFps = Swift.min(minFps, conf.minFps)
      maxFps = Swift.max(maxFps, conf.maxFps)
      minFieldOfView = Swift.min(minFieldOfView, conf.fieldOfView)
      maxFieldOfView = Swift.max(maxFieldOfView, conf.fieldOfView)
    }
    return CKUIAdjustableCameraConfiguration(
      sizes: sizes,
      minZoom: minZoom,
      maxZoom: maxZoom,
      minFps: minFps,
      maxFps: maxFps,
      minFieldOfView: minFieldOfView,
      maxFieldOfView: maxFieldOfView,
      isVideoMirroringAvailable: isVideoMirroringAvailable,
      supportedStabilizationModes: supportedStabilizationModes,
      isMulticamAvailable: isMulticamAvailable
    )
  }
}
