import CameraKit
import Foundation
import AutocontainerKit

struct SessionMediaChunkMaker: CKMediaChunkMaker {
  let fileManager: FileManager
  let timestampMaker: CKTimestampMaker

  func makeMediaChunk(deviceId: CKDeviceID, fileType: CKFileType) -> CKMediaChunk {
    print("Chunk: \(deviceId.value), fileType: \(fileType.rawValue)")
    return CKMediaChunk(
      timestamp: timestampMaker.currentTimestamp,
      url: fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(UUID().uuidString),
      deviceId: deviceId,
      fileType: fileType
    )
  }
}
