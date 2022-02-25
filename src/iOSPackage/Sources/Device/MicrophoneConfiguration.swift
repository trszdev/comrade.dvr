public struct MicrophoneConfiguration: Equatable {
  public init(deviceLocation: DeviceLocation, quality: Quality, polarPattern: PolarPattern) {
    self.deviceLocation = deviceLocation
    self.quality = quality
    self.polarPattern = polarPattern
  }

  public static let `default` = Self(deviceLocation: .default, quality: .high, polarPattern: .stereo)

  public let deviceLocation: DeviceLocation
  public let quality: Quality
  public let polarPattern: PolarPattern
}
