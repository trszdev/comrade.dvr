import Combine

public protocol CKManager {
  func permissionStatus(for mediaType: CKMediaType) -> AnyPublisher<Bool?, Never>
  func requestPermission(for mediaType: CKMediaType) -> AnyPublisher<Void, CKPermissionError>
  var sessionMakerPublisher: AnyPublisher<CKSessionMaker, CKPermissionError> { get }
}
