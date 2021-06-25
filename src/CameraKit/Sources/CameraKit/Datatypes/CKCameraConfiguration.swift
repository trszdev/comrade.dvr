import Foundation

public struct CKCameraConfiguration: Identifiable, Hashable, Codable, Equatable {
  public var id: CKDeviceConfigurationID
  public var size: CKSize
  public var zoom: Double
  public var fps: Int
  public var fieldOfView: Int
  public var orientation: CKOrientation
  public var autoFocus: CKAutoFocus
  public var stabilizationMode: CKStabilizationMode
  public var videoGravity: CKVideoGravity
  public var videoQuality: CKQuality
  public var useH265: Bool
  public var bitrate: CKBitrate

  public init(
    size: CKSize,
    zoom: Double,
    fps: Int,
    fieldOfView: Int,
    orientation: CKOrientation,
    autoFocus: CKAutoFocus,
    stabilizationMode: CKStabilizationMode,
    videoGravity: CKVideoGravity,
    videoQuality: CKQuality,
    useH265: Bool,
    bitrate: CKBitrate
  ) {
    self.id = CKDeviceConfigurationID(value: UUID().uuidString)
    self.size = size
    self.zoom = zoom
    self.fps = fps
    self.fieldOfView = fieldOfView
    self.orientation = orientation
    self.autoFocus = autoFocus
    self.stabilizationMode = stabilizationMode
    self.videoGravity = videoGravity
    self.videoQuality = videoQuality
    self.useH265 = useH265
    self.bitrate = bitrate
  }

  init(
    id: CKDeviceConfigurationID,
    size: CKSize,
    zoom: Double,
    fps: Int,
    fieldOfView: Int,
    orientation: CKOrientation,
    autoFocus: CKAutoFocus,
    stabilizationMode: CKStabilizationMode,
    videoGravity: CKVideoGravity,
    videoQuality: CKQuality,
    useH265: Bool,
    bitrate: CKBitrate
  ) {
    self.id = id
    self.size = size
    self.zoom = zoom
    self.fps = fps
    self.fieldOfView = fieldOfView
    self.orientation = orientation
    self.autoFocus = autoFocus
    self.stabilizationMode = stabilizationMode
    self.videoGravity = videoGravity
    self.videoQuality = videoQuality
    self.useH265 = useH265
    self.bitrate = bitrate
  }
}
