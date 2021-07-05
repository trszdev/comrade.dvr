import Foundation

public struct CKMediaChunk: Hashable {
  public init(
    timestamp: CKTimestamp,
    url: URL,
    deviceId: CKDeviceID,
    fileType: CKFileType
  ) {
    self.timestamp = timestamp
    self.url = url
    self.deviceId = deviceId
    self.fileType = fileType
  }

  public let timestamp: CKTimestamp
  public let url: URL
  public let deviceId: CKDeviceID
  public let fileType: CKFileType

  func with(timestamp: CKTimestamp) -> CKMediaChunk {
    CKMediaChunk(timestamp: timestamp, url: url, deviceId: deviceId, fileType: fileType)
  }
}
