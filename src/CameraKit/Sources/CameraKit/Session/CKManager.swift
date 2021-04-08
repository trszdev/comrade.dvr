import Combine

public protocol CKManager: CKPermissionManager {
  var sessionMakerPublisher: AnyPublisher<CKSessionMaker, CKPermissionError> { get }
}
