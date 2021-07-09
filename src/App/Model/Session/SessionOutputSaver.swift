import CameraKit
import Foundation

protocol SessionOutputSaver {
  func save(mediaChunk: CKMediaChunk)
}

struct SessionOutputSaverImpl: SessionOutputSaver {
  func save(mediaChunk: CKMediaChunk) {
    print(mediaChunk.url)
  }
}
