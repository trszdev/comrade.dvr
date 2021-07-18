import Combine
import CameraKit
import Foundation

struct PreviewMediaChunkRepository: MediaChunkRepository {
  var mediaChunkPublisher: AnyPublisher<MediaChunk, Never> {
    PassthroughSubject<MediaChunk, Never>().eraseToAnyPublisher()
  }

  var errorPublisher: AnyPublisher<Error, Never> {
    PassthroughSubject<Error, Never>().eraseToAnyPublisher()
  }

  func availableSelections() -> Future<[CKDeviceID: Set<Date>], Never> {
    Future<[CKDeviceID: Set<Date>], Never> { promise in promise(.success([:])) }
  }

  func mediaChunks(device: CKDeviceID, day: Date) -> Future<[MediaChunk], Never> {
    Future<[MediaChunk], Never> { promise in promise(.success([])) }
  }

  func deleteMediaChunks(with url: URL) {
  }

  func save(mediaChunk: CKMediaChunk, sessionStartupInfo: CKSessionStartupInfo) {
  }
}
