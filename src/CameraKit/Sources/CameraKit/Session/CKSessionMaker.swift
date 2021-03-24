public protocol CKSessionMaker {
  var adjustableConfiguration: CKAdjustableConfiguration { get }
  var nearestConfigurationPicker: CKNearestConfigurationPicker { get }
  func makeSession(configuration: CKConfiguration) -> CKSession
}
