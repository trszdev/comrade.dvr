import Util
import Assets
import Foundation

public struct Settings: Codable, Equatable {
  public init(
    totalFileSize: FileSize? = .gigabytes(5),
    maxFileLength: TimeInterval = .minutes(1),
    language: Language? = nil,
    appearance: Appearance? = nil,
    autoStart: Bool = false,
    recordingNotifications: Bool = true
  ) {
    self.totalFileSize = totalFileSize
    self.maxFileLength = maxFileLength
    self.language = language
    self.appearance = appearance
    self.autoStart = autoStart
    self.recordingNotifications = recordingNotifications
  }

  public var totalFileSize: FileSize? = .gigabytes(5)
  public var maxFileLength: TimeInterval = .minutes(1)
  public var language: Language?
  public var appearance: Appearance?
  public var autoStart: Bool
  public var recordingNotifications: Bool
}
