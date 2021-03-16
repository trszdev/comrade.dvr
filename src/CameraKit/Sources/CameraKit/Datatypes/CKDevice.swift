public struct CKDevice<Configuration: Hashable>: Identifiable, Hashable {
  public let id: CKDeviceID
  public let configuration: Configuration

  public init(id: CKDeviceID, configuration: Configuration) {
    self.id = id
    self.configuration = configuration
  }
}
