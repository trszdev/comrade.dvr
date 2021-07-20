import Foundation

public protocol CKTimestampMaker {
  var currentTimestamp: CKTimestamp { get }
}

public protocol CKTimestampMakerBuilder {
  func makeTimestampMaker() -> CKTimestampMaker
}

struct CKTimestampMakerBuilderImpl: CKTimestampMakerBuilder {
  func makeTimestampMaker() -> CKTimestampMaker {
    CKTimestampMakerImpl()
  }
}

struct CKTimestampMakerImpl: CKTimestampMaker {
  let startTimestamp = DispatchTime.now().uptimeNanoseconds

  var currentTimestamp: CKTimestamp {
    CKTimestamp(nanoseconds: DispatchTime.now().uptimeNanoseconds - startTimestamp)
  }
}
