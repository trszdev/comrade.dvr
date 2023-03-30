import Foundation
import Device
import Util

public struct DeviceConfiguration: Hashable {
  public init(
    frontCamera: CameraConfiguration? = nil,
    backCamera: CameraConfiguration? = nil,
    microphone: MicrophoneConfiguration? = nil,
    maxFileLength: TimeInterval = .seconds(1),
    orientation: Orientation = .portrait
  ) {
    self.frontCamera = frontCamera
    self.backCamera = backCamera
    self.microphone = microphone
    self.maxFileLength = maxFileLength
    self.orientation = orientation
  }

  public var frontCamera: CameraConfiguration?
  public var backCamera: CameraConfiguration?
  public var microphone: MicrophoneConfiguration?
  public var maxFileLength: TimeInterval = .seconds(1)
  public var orientation: Orientation = .portrait
}
