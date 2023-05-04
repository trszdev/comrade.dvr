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

  public func makeSession() -> Session? {
    let hasBackCamera = backCamera != nil
    let hasFrontCamera = frontCamera != nil
    switch (hasBackCamera, hasFrontCamera) {
    case (true, true):
      return .init(multiCameraSession: .init())
    case (true, false):
      return .init(backCameraSession: .init())
    case (false, true):
      return .init(frontCameraSession: .init())
    case (false, false):
      return nil
    }
  }
}
