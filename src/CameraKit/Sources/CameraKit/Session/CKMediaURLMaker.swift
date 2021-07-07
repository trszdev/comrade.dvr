import Foundation

public protocol CKMediaURLMaker {
  func makeMediaURL(deviceId: CKDeviceID, sessionStartupInfo: CKSessionStartupInfo, startedAt: CKTimestamp) -> URL
}

public struct CKTempMediaURLMaker: CKMediaURLMaker {
  let tempFileMaker: CKTempFileMaker

  public func makeMediaURL(
    deviceId: CKDeviceID,
    sessionStartupInfo: CKSessionStartupInfo,
    startedAt: CKTimestamp
  ) -> URL {
    tempFileMaker.makeTempFile()
  }
}
