public protocol CKSessionMaker {
  func makeSession(configuration: CKConfiguration) throws -> CKSession
}
