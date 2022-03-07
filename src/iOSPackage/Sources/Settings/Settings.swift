import Util
import Assets
import Foundation

public struct Settings: Codable, Equatable {
  public init(
    totalFileSize: FileSize? = .gigabytes(5),
    maxFileLength: TimeInterval = .minutes(1),
    orientation: Settings.Orientation? = nil,
    language: Language? = nil,
    appearance: Appearance? = nil,
    autoStart: Bool = false,
    recordingNotifications: Bool = true
  ) {
    self.totalFileSize = totalFileSize
    self.maxFileLength = maxFileLength
    self.orientation = orientation
    self.language = language
    self.appearance = appearance
    self.autoStart = autoStart
    self.recordingNotifications = recordingNotifications
  }

  public enum Orientation: CaseIterable, Codable {
    case portrait
    case landscape
  }

  public var totalFileSize: FileSize? = .gigabytes(5)
  public var maxFileLength: TimeInterval = .minutes(1)
  public var orientation: Orientation?
  public var language: Language?
  public var appearance: Appearance?
  public var autoStart: Bool
  public var recordingNotifications: Bool
}
