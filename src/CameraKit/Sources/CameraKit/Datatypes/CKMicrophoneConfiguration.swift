import Foundation

public struct CKMicrophoneConfiguration: Identifiable, Hashable {
  public let id: CKDeviceConfigurationID

  public init() {
    self.id = CKDeviceConfigurationID(value: UUID().uuidString)
  }

  init(id: CKDeviceConfigurationID) {
    self.id = id
  }
}
