public protocol CKSessionMaker {
  var adjustableConfiguration: CKAdjustableCameraConfiguration { get }
  func makeSession(configuration: CKConfiguration) -> CKSession?
}
