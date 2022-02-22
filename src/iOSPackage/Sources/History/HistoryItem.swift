import Util
import Foundation

public struct HistoryItem: Equatable {
  public enum PreviewType {
    case video
    case audio
  }

  public init(
    createdAt: Date,
    duration: TimeInterval,
    url: URL,
    size: FileSize,
    deviceName: String,
    previewType: PreviewType
  ) {
    self.createdAt = createdAt
    self.duration = duration
    self.url = url
    self.size = size
    self.deviceName = deviceName
    self.previewType = previewType
  }

  public var createdAt: Date
  public var duration: TimeInterval
  public var url: URL
  public var size: FileSize
  public var deviceName: String
  public var previewType: PreviewType

  public static let mockAudio: Self = .init(
    createdAt: .init(),
    duration: .seconds(3),
    url: URL(string: "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3")!,
    size: .megabytes(10),
    deviceName: "Front mic",
    previewType: .audio
  )

  public static let mockVideo: Self = .init(
    createdAt: .init(),
    duration: .seconds(3),
    url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
    size: .megabytes(10),
    deviceName: "Back camera",
    previewType: .video
  )
}
