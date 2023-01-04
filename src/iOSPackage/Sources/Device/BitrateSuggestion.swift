import Foundation

public struct BitrateSuggestion: Identifiable {
  public var id = UUID()

  public init(resolution: Resolution, fps: Int, bitrate: Bitrate, description: String) {
    self.resolution = resolution
    self.fps = fps
    self.bitrate = bitrate
    self.description = description
  }

  public let resolution: Resolution
  public let fps: Int
  public let bitrate: Bitrate
  public let description: String

  public static let p2160: [Self] = [
    Resolution.p2160.bitrateSuggestion(fps: 30, bitrate: 35_000_000, description: "2160p 30FPS SDR"),
    Resolution.p2160.bitrateSuggestion(fps: 60, bitrate: 53_000_000, description: "2160p 60FPS SDR"),
    Resolution.p2160.bitrateSuggestion(fps: 30, bitrate: 44_000_000, description: "2160p 30FPS HDR"),
    Resolution.p2160.bitrateSuggestion(fps: 60, bitrate: 66_000_000, description: "2160p 60FPS HDR"),
  ]

  public static let p1440: [Self] = [
    Resolution.p1440.bitrateSuggestion(fps: 30, bitrate: 16_000_000, description: "1440p 30FPS SDR"),
    Resolution.p1440.bitrateSuggestion(fps: 60, bitrate: 24_000_000, description: "1440p 60FPS SDR"),
    Resolution.p1440.bitrateSuggestion(fps: 30, bitrate: 20_000_000, description: "1440p 30FPS HDR"),
    Resolution.p1440.bitrateSuggestion(fps: 60, bitrate: 30_000_000, description: "1440p 60FPS HDR"),
  ]

  public static let p1080: [Self] = [
    Resolution.p1080.bitrateSuggestion(fps: 30, bitrate: 8_000_000, description: "1080p 30FPS SDR"),
    Resolution.p1080.bitrateSuggestion(fps: 60, bitrate: 12_000_000, description: "1080p 60FPS SDR"),
    Resolution.p1080.bitrateSuggestion(fps: 30, bitrate: 10_000_000, description: "1080p 30FPS HDR"),
    Resolution.p1080.bitrateSuggestion(fps: 60, bitrate: 15_000_000, description: "1080p 60FPS HDR"),
  ]

  public static let p720: [Self] = [
    Resolution.p720.bitrateSuggestion(fps: 30, bitrate: 5_000_000, description: "720p 30FPS SDR"),
    Resolution.p720.bitrateSuggestion(fps: 60, bitrate: 7_500_000, description: "720p 60FPS SDR"),
    Resolution.p720.bitrateSuggestion(fps: 30, bitrate: 6_500_000, description: "720p 30FPS HDR"),
    Resolution.p720.bitrateSuggestion(fps: 60, bitrate: 9_500_000, description: "720p 60FPS HDR"),
  ]

  public static let p480: [Self] = [
    Resolution.p480.bitrateSuggestion(fps: 30, bitrate: 2_500_000, description: "480p 30FPS SDR"),
    Resolution.p480.bitrateSuggestion(fps: 60, bitrate: 4_000_000, description: "480p 60FPS SDR"),
  ]

  public static let all: [Resolution: [Self]] = [
    .p480: BitrateSuggestion.p480,
    .p720: BitrateSuggestion.p720,
    .p1080: BitrateSuggestion.p1080,
    .p1440: BitrateSuggestion.p1440,
    .p2160: BitrateSuggestion.p2160,
  ]
}

private extension Resolution {
  func bitrateSuggestion(fps: Int, bitrate: Int, description: String) -> BitrateSuggestion {
    .init(resolution: self, fps: fps, bitrate: .init(bitsPerSecond: bitrate), description: description)
  }
}
