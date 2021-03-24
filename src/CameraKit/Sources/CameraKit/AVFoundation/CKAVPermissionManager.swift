import AVFoundation
import Combine

struct CKAVPermissionManager: CKPermissionManager {
  let infoPlistBundle: Bundle?

  func permissionStatus(for mediaType: CKMediaType) -> AnyPublisher<Bool?, Never> {
    let result: Bool?
    let status = AVCaptureDevice.authorizationStatus(for: mediaType.avMediaType)
    switch status {
    case .authorized:
      result = true
    case .restricted, .denied:
      result = false
    case .notDetermined:
      result = nil
    @unknown default:
      assert(false, "Unknown authorization status: \(status)")
      result = false
    }
    return Just(result).setFailureType(to: Never.self).eraseToAnyPublisher()
  }

  func requestPermission(for mediaType: CKMediaType) -> AnyPublisher<Void, CKPermissionError> {
    let subject = PassthroughSubject<Void, CKPermissionError>()
    if let bundle = infoPlistBundle, !(bundle.object(forInfoDictionaryKey: mediaType.infoPlistKey) is String) {
      subject.send(completion: .failure(.noDescription(mediaType: mediaType)))
      return subject.eraseToAnyPublisher()
    }
    AVCaptureDevice.requestAccess(for: mediaType.avMediaType) { granted in
      guard granted else {
        return subject.send(completion: .failure(.noPermission(mediaType: mediaType)))
      }
      subject.send()
      subject.send(completion: .finished)
    }
    return subject.eraseToAnyPublisher()
  }
}
