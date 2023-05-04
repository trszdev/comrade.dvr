import Foundation

public struct DeviceConfiguration: Hashable, Codable {
  public init(
    frontCamera: CameraConfiguration = CameraConfiguration.defaultFrontCamera,
    frontCameraEnabled: Bool = false,
    backCamera: CameraConfiguration = CameraConfiguration.defaultBackCamera,
    backCameraEnabled: Bool = true,
    microphone: MicrophoneConfiguration = MicrophoneConfiguration.default,
    microphoneEnabled: Bool = true
  ) {
    self.frontCamera = frontCamera
    self.frontCameraEnabled = frontCameraEnabled
    self.backCamera = backCamera
    self.backCameraEnabled = backCameraEnabled
    self.microphone = microphone
    self.microphoneEnabled = microphoneEnabled
  }

  public var frontCamera = CameraConfiguration.defaultFrontCamera
  public var frontCameraEnabled = false
  public var backCamera = CameraConfiguration.defaultBackCamera
  public var backCameraEnabled = true
  public var microphone = MicrophoneConfiguration.default
  public var microphoneEnabled = true
}
