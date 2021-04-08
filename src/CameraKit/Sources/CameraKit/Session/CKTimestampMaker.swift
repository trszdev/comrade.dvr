import Foundation

protocol CKTimestampMaker {
  var currentTimestamp: CKTimestamp { get }
}

struct CKTimestampMakerImpl: CKTimestampMaker {
  let startTimestamp = DispatchTime.now().uptimeNanoseconds

  var currentTimestamp: CKTimestamp {
    CKTimestamp(nanoseconds: DispatchTime.now().uptimeNanoseconds - startTimestamp)
  }
}
