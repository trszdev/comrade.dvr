public struct CameraConfigurationIndex: Equatable {
  public struct FpsAndZoom: Equatable {
    public init(fps: ClosedRange<Int> = 1...60, zoom: ClosedRange<Double> = 1...2) {
      self.fps = fps
      self.zoom = zoom
    }

    public var fps: ClosedRange<Int>
    public var zoom: ClosedRange<Double>
  }

  public struct FovIndex: Equatable {
    public init(fovs: [Fov] = [], index: [Fov: FpsAndZoom] = [:]) {
      self.fovs = fovs
      self.index = index
    }

    public var fovs: [Fov]
    public var index: [Fov: FpsAndZoom]
  }

  public init(resolutions: [Resolution] = [], index: [Resolution: FovIndex] = [:]) {
    self.resolutions = resolutions
    self.index = index
  }

  public var resolutions: [Resolution]
  public var index: [Resolution: FovIndex]

  public static let mock = Self(
    resolutions: [.p1440, .p1080],
    index: [
      .p1080: .init(
        fovs: [70.921, 100.50],
        index: [70.921: .init(fps: 10...100, zoom: 1...2), 100.50: .init(fps: 2...30, zoom: 1...4)]
      ),
      .p1440: .init(
        fovs: [100.50, 120],
        index: [
          100.50: .init(fps: 2...30, zoom: 1...4),
          120: .init(fps: 4...60, zoom: 1...4),
        ]
      ),
    ]
  )
}
