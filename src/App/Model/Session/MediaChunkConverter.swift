import CameraKit
import Foundation

protocol MediaChunkConverter {
  func makeMediaChunk(from ckMediaChunk: CKMediaChunk, with sessionStartupInfo: CKSessionStartupInfo) -> MediaChunk?
}

struct MediaChunkConverterImpl: MediaChunkConverter {
  let calendar: Calendar

  func makeMediaChunk(from ckMediaChunk: CKMediaChunk, with sessionStartupInfo: CKSessionStartupInfo) -> MediaChunk? {
    let dateStarted = calendar.date(
      byAdding: .nanosecond,
      value: Int(ckMediaChunk.startedAt.nanoseconds),
      to: sessionStartupInfo.startedAt
    )
    let dateFinished = calendar.date(
      byAdding: .nanosecond,
      value: Int(ckMediaChunk.finishedAt.nanoseconds),
      to: sessionStartupInfo.startedAt
    )
    guard let day = dateStarted.flatMap(calendar.startOfDay),
      let startedAt = dateStarted?.timeIntervalSince(day),
      let finishedAt = dateFinished?.timeIntervalSince(day)
    else {
      return nil
    }
    return MediaChunk(
      startedAt: CKTimestamp(nanoseconds: UInt64(startedAt.nanoseconds)),
      url: ckMediaChunk.url,
      deviceId: ckMediaChunk.deviceId,
      fileType: ckMediaChunk.fileType,
      finishedAt: CKTimestamp(nanoseconds: UInt64(finishedAt.nanoseconds)),
      day: day
    )
  }
}
