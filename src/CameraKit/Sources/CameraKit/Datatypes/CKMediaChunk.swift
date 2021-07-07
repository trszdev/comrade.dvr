import Foundation

public struct CKMediaChunk: Hashable {
  public init(
    startedAt: CKTimestamp,
    url: URL,
    deviceId: CKDeviceID,
    fileType: CKFileType,
    finishedAt: CKTimestamp
  ) {
    self.startedAt = startedAt
    self.url = url
    self.deviceId = deviceId
    self.fileType = fileType
    self.finishedAt = finishedAt
  }

  public let startedAt: CKTimestamp
  public let url: URL
  public let deviceId: CKDeviceID
  public let fileType: CKFileType
  public let finishedAt: CKTimestamp

  func with(finishedAt: CKTimestamp) -> CKMediaChunk {
    CKMediaChunk(startedAt: startedAt, url: url, deviceId: deviceId, fileType: fileType, finishedAt: finishedAt)
  }
}
