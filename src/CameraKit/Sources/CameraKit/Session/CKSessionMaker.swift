public protocol CKSessionMaker {
  var adjustableConfiguration: CKAdjustableConfiguration { get }
  func makeSession(configuration: CKConfiguration) throws -> CKSession
}
