import CameraKit
import Foundation
import AutocontainerKit

struct SessionMediaURLMaker: CKMediaURLMaker {
  let fileManager: FileManager
  let calendar: Calendar
  let tempMediaURLMaker: CKTempMediaURLMaker

  func makeMediaURL(deviceId: CKDeviceID, sessionStartupInfo: CKSessionStartupInfo, startedAt: CKTimestamp) -> URL {
    let tempFileUrl = tempMediaURLMaker.makeMediaURL(
      deviceId: deviceId,
      sessionStartupInfo: sessionStartupInfo,
      startedAt: startedAt
    )
    let offset = Int(startedAt.nanoseconds)
    guard let date = calendar.date(byAdding: .nanosecond, value: offset, to: sessionStartupInfo.startedAt) else {
      return tempFileUrl
    }
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
