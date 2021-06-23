public struct CKUIAdjustableCameraConfiguration: Hashable {
  public let sizes: Set<CKSize>
  public let minZoom: Double
  public let maxZoom: Double
  public let minFps: Int
  public let maxFps: Int
  public let minFieldOfView: Int
  public let maxFieldOfView: Int
  public let supportedStabilizationModes: Set<CKStabilizationMode>
  public let isMulticamAvailable: Bool

  public init(
    sizes: Set<CKSize>,
    minZoom: Double,
    maxZoom: Double,
    minFps: Int,
    maxFps: Int,
    minFieldOfView: Int,
    maxFieldOfView: Int,
    supportedStabilizationModes: Set<CKStabilizationMode>,
    isMulticamAvailable: Bool
  ) {
    self.sizes = sizes
    self.minZoom = minZoom
    self.maxZoom = maxZoom
    self.minFps = minFps
    self.maxFps = maxFps
    self.minFieldOfView = minFieldOfView
    self.maxFieldOfView = maxFieldOfView
    self.supportedStabilizationModes = supportedStabilizationModes
    self.isMulticamAvailable = isMulticamAvailable
  }
}

public extension Array where Element == CKAdjustableCameraConfiguration {
  var ui: CKUIAdjustableCameraConfiguration {
    var sizes = Set<CKSize>()
    var minZoom = Double.greatestFiniteMagnitude
    var maxZoom = -Double.greatestFiniteMagnitude
    var minFps = Int.max
    var maxFps = Int.min
    var minFieldOfView = Int.max
    var maxFieldOfView = Int.min
    var isMulticamAvailable = false
    var supportedStabilizationModes = Set<CKStabilizationMode>()
    for conf in self {
      sizes.insert(conf.size)
      supportedStabilizationModes.formUnion(conf.supportedStabilizationModes)
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
      supportedStabilizationModes: supportedStabilizationModes,
      isMulticamAvailable: isMulticamAvailable
    )
  }
}
