import Foundation

protocol CKTempFileMaker {
  func makeTempFile() -> URL
}

struct CKTempFileMakerImpl: CKTempFileMaker {
  func makeTempFile() -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString)
  }
}
