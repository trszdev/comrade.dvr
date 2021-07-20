import CameraKit
import Foundation
import AutocontainerKit

struct SessionMediaURLMaker: CKMediaURLMaker {
  let fileManager: FileManager
  let tempMediaURLMaker: CKTempMediaURLMaker

  func makeMediaURL(deviceId: CKDeviceID, sessionStartupInfo: CKSessionStartupInfo, startedAt: CKTimestamp) -> URL {
    let tempFileUrl = tempMediaURLMaker.makeMediaURL(
      deviceId: deviceId,
      sessionStartupInfo: sessionStartupInfo,
      startedAt: startedAt
    )
    let date = sessionStartupInfo.startedAt.addingTimeInterval(.from(nanoseconds: Double(startedAt.nanoseconds)))
    let sessionDirectory = fileManager.documentsDirectory
      .appendingPathComponent(date.dayMonthYear)
      .appendingPathComponent(sessionStartupInfo.id.uuidString)
      .appendingPathComponent(deviceId.value)
    let mediaUrl = sessionDirectory.appendingPathComponent(date.hourMinuteSecond, isDirectory: false)
    var isDirectory: ObjCBool = false
    if fileManager.fileExists(atPath: sessionDirectory.path, isDirectory: &isDirectory), isDirectory.boolValue {
      return mediaUrl
    } else {
      do {
        try fileManager.createDirectory(at: mediaUrl, withIntermediateDirectories: true, attributes: nil)
        return mediaUrl
      } catch {
        print(error.localizedDescription)
      }
    }
    return tempFileUrl
  }
}

private extension Date {
  var dayMonthYear: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: self)
  }

  var hourMinuteSecond: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH-mm-ss"
    return formatter.string(from: self)
  }
}
