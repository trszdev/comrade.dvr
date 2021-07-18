import CameraKit
import Foundation

struct MediaChunk {
  let startedAt: CKTimestamp
  let url: URL
  let deviceId: CKDeviceID
  let fileType: CKFileType
  let finishedAt: CKTimestamp
  let day: Date
}
