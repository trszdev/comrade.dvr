public protocol CKSessionMaker {
  var configurationPicker: CKNearestConfigurationPicker { get }
  var adjustableConfiguration: CKAdjustableConfiguration { get }
  func makeSession(configuration: CKConfiguration) throws -> CKSession
}
