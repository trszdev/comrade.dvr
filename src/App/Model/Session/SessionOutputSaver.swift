import CameraKit

protocol SessionOutputSaver {
  func save(mediaChunk: CKMediaChunk)
}
