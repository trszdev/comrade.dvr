import Foundation

public protocol CKSessionDelegate: AnyObject {
  func sessionDidOutput(mediaChunk: CKMediaChunk)
  func sessionDidOutput(error: Error)
  func sessionDidChangePressureLevel()
}
