public struct CameraConfiguration: Equatable {
  public init(
    fps: Int,
    resolution: Resolution,
    bitrate: Bitrate,
    useH265: Bool,
    zoom: Double,
    fov: Int,
    quality: Quality
  ) {
    self.fps = fps
    self.resolution = resolution
    self.bitrate = bitrate
    self.useH265 = useH265
    self.zoom = zoom
    self.fov = fov
    self.quality = quality
  }

  public var fps: Int
  public var resolution: Resolution
  public var bitrate: Bitrate
  public var useH265: Bool
  public var zoom: Double
  public var fov: Int
  public var quality: Quality

  public static let defaultFrontCamera = Self(
    fps: 30,
    resolution: .p1080,
    bitrate: BitrateSuggestion.p1080[0].bitrate,
    useH265: false,
    zoom: 1,
    fov: 100,
    quality: .high
  )

  public static let defaultBackCamera = Self(
    fps: 30,
    resolution: .p1080,
    bitrate: BitrateSuggestion.p1080[0].bitrate,
    useH265: false,
    zoom: 1,
    fov: 70,
    quality: .high
  )
}
