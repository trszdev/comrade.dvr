import Foundation

public struct CKMediaChunk {
  public let timestamp: CKTimestamp
  public let url: URL
  public let deviceId: CKDeviceID
  public let fileType: CKFileType

  func with(timestamp: CKTimestamp) -> CKMediaChunk {
    CKMediaChunk(timestamp: timestamp, url: url, deviceId: deviceId, fileType: fileType)
  }
}
