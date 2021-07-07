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
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dateString = formatter.string(from: date)
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let sessionDirectory = documentsDirectory
      .appendingPathComponent(dateString)
      .appendingPathComponent(sessionStartupInfo.id.uuidString)
    var isDirectory: ObjCBool = false
    if fileManager.fileExists(atPath: sessionDirectory.path, isDirectory: &isDirectory), isDirectory.boolValue {
      return sessionDirectory.appendingPathComponent(deviceId.value)
    } else {
      do {
        try fileManager.createDirectory(at: sessionDirectory, withIntermediateDirectories: true, attributes: nil)
        return sessionDirectory.appendingPathComponent(deviceId.value)
      } catch {
        print(error.localizedDescription)
      }
    }
    return tempFileUrl
  }
}
