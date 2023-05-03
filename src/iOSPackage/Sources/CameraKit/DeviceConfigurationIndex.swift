import Device

public struct DeviceConfigurationIndex: Equatable {
  public init(
    backCamera: CameraConfigurationIndex,
    frontCamera: CameraConfigurationIndex
  ) {
    self.backCamera = backCamera
    self.frontCamera = frontCamera
  }

  public var backCamera: CameraConfigurationIndex
  public var frontCamera: CameraConfigurationIndex
}
