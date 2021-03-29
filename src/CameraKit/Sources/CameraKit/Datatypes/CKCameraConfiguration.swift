import Foundation

public struct CKCameraConfiguration: Identifiable, Hashable {
  public let id: CKDeviceConfigurationID
  public let size: CKSize
  public let zoom: Double
  public let fps: Int
  public let fieldOfView: Int
  public let orientation: CKOrientation
  public let autoFocus: CKAutoFocus
  public let stabilizationMode: CKStabilizationMode
  public let videoGravity: CKVideoGravity

  public init(
    size: CKSize,
    zoom: Double,
    fps: Int,
    fieldOfView: Int,
    orientation: CKOrientation,
    autoFocus: CKAutoFocus,
    stabilizationMode: CKStabilizationMode,
    videoGravity: CKVideoGravity
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
    videoGravity: CKVideoGravity
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
  }
}
