import Util
import Foundation
import Assets

public struct HistoryItem: Equatable {
  public enum PreviewType {
    case video
    case selfie
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
    duration: .minutes(1),
    url: URL(string: "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3")!,
    size: .bytes(1024 * 817 + 589),
    deviceName: "microphone",
    previewType: .audio
  )

  public static let mockVideo: Self = .init(
    createdAt: .init(),
    duration: .minutes(1),
    url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
    size: .kilobytes(58 * 1024 + 669),
    deviceName: "camera",
    previewType: .video
  )

  public static func makePreviews(amount: Int) -> [Self] {
    let date = Date(timeIntervalSinceReferenceDate: 0)
    let audios = (0...amount).map {
      var item = mockAudio
      item.url = URL(string: "https://www.learningcontainer.com/a\($0)")!
      item.createdAt = date + .minutes(Double($0))
      return item
    }
    let backCameras = (0...amount).map {
      var item = mockVideo
      item.url = URL(string: "https://www.learningcontainer.com/b\($0)")!
      item.createdAt = date + .minutes(Double($0))
      return item
    }
    let selfies = (0...amount).map {
      var item = mockVideo
      item.url = URL(string: "https://www.learningcontainer.com/c\($0)")!
      item.createdAt = date + .minutes(Double($0))
      item.deviceName = "selfie"
      item.previewType = .selfie
      return item
    }
    return zip(audios, zip(backCameras, selfies)).flatMap { (audio, cameras) in [cameras.0, cameras.1, audio] }
  }
}
