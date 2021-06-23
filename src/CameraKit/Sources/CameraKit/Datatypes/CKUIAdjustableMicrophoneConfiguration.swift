public struct CKUIAdjustableMicrophoneConfiguration: Hashable {
  public let locations: Set<CKDeviceLocation>
  public let polarPatterns: Set<CKPolarPattern>

  public init(locations: Set<CKDeviceLocation>, polarPatterns: Set<CKPolarPattern>) {
    self.locations = locations
    self.polarPatterns = polarPatterns
  }
}

public extension Array where Element == CKAdjustableMicrophoneConfiguration {
  var ui: CKUIAdjustableMicrophoneConfiguration {
    CKUIAdjustableMicrophoneConfiguration(
      locations: Set(map(\.location)),
      polarPatterns: Set(map(\.polarPattern))
    )
  }
}
