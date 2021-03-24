import Combine

public protocol CKPermissionManager {
  func permissionStatus(for mediaType: CKMediaType) -> AnyPublisher<Bool?, Never>
  func requestPermission(for mediaType: CKMediaType) -> AnyPublisher<Void, CKPermissionError>
}
