import Combine
import CameraKit
import Foundation
import Util

struct PreviewMediaChunkRepository: MediaChunkRepository {
  var lastCapturePublisher: AnyPublisher<Date?, Never> {
    CurrentValueSubject<Date?, Never>(PreviewHistoryViewModel.captureDate).eraseToAnyPublisher()
  }

  var totalFileSizePublisher: AnyPublisher<FileSize?, Never> {
    CurrentValueSubject<FileSize?, Never>(FileSize.from(megabytes: 112 * 5)).eraseToAnyPublisher()
  }

  var mediaChunkPublisher: AnyPublisher<MediaChunk, Never> {
    PassthroughSubject<MediaChunk, Never>().eraseToAnyPublisher()
  }

  var errorPublisher: AnyPublisher<Error, Never> {
    PassthroughSubject<Error, Never>().eraseToAnyPublisher()
  }

  var availableSelectionsPublisher: AnyPublisher<[CKDeviceID: Set<Date>], Never> {
    CurrentValueSubject<[CKDeviceID: Set<Date>], Never>([:]).eraseToAnyPublisher()
  }

  func mediaChunks(device: CKDeviceID, day: Date) -> Future<[MediaChunk], Never> {
    Future<[MediaChunk], Never> { promise in promise(.success([])) }
  }

  func deleteMediaChunks(with url: URL) {
  }

  func deleteAllMediaChunks() {
  }

  func save(mediaChunk: CKMediaChunk, sessionStartupInfo: CKSessionStartupInfo) {
  }
}
