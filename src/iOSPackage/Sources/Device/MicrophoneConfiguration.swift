public struct MicrophoneConfiguration: Hashable, Codable {
  public init(quality: Quality, polarPattern: PolarPattern) {
    self.quality = quality
    self.polarPattern = polarPattern
  }

  public static let `default` = Self(quality: .high, polarPattern: .stereo)

  public var quality: Quality
  public var polarPattern: PolarPattern
}
