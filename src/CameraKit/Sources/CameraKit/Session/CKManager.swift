import Combine

public protocol CKManager: CKPermissionManager, CKConfigurationManager {
  var sessionMakerPublisher: AnyPublisher<CKSessionMaker, CKPermissionError> { get }
}
