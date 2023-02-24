import Foundation
import Device
import Util

public struct DeviceConfiguration {
  var frontCamera: CameraConfiguration?
  var backCamera: CameraConfiguration?
  var microphone: MicrophoneConfiguration?
  var maxFileLength: TimeInterval = .seconds(1)
  var orientation: Orientation = .portrait
}
