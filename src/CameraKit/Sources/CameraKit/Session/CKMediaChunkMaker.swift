protocol CKMediaChunkMaker {
  func makeMediaChunk(deviceId: CKDeviceID, fileType: CKFileType) -> CKMediaChunk
}

struct CKMediaChunkMakerImpl: CKMediaChunkMaker {
  let timestampMaker: CKTimestampMaker
  let tempFileMaker: CKTempFileMaker

  func makeMediaChunk(deviceId: CKDeviceID, fileType: CKFileType) -> CKMediaChunk {
    CKMediaChunk(
      timestamp: timestampMaker.currentTimestamp,
      url: tempFileMaker.makeTempFile(),
      deviceId: deviceId,
      fileType: fileType
    )
  }
}
