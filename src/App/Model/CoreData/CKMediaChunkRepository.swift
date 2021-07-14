import CameraKit
import Combine
import Foundation

protocol CKMediaChunkRepository: SessionOutputSaver {
  var mediaChunkPublisher: AnyPublisher<CKMediaChunk, Never> { get }
  var errorPublisher: AnyPublisher<Error, Never> { get }
  func availableSelections() -> Future<[CKDeviceID: [Date]], Never>
  func mediaChunks(device: CKDeviceID, day: Date) -> Future<[CKMediaChunk], Never>
  func deleteMediaChunks(with url: URL)
}

final class CKMediaChunkRepositoryImpl: CKMediaChunkRepository {
  init(coreDataController: CoreDataController) {
    self.coreDataController = coreDataController
  }

  var mediaChunkPublisher: AnyPublisher<CKMediaChunk, Never> { mediaChunkSubject.eraseToAnyPublisher() }
  var errorPublisher: AnyPublisher<Error, Never> { errorSubject.eraseToAnyPublisher() }

  func availableSelections() -> Future<[CKDeviceID: [Date]], Never> {
    Future { promise in
      promise(.success([CKDeviceID(value: "back-camera"): [Date()] ]))
    }
  }

  func mediaChunks(device: CKDeviceID, day: Date) -> Future<[CKMediaChunk], Never> {
    Future { promise in
      promise(.success([
        CKMediaChunk(
          startedAt: CKTimestamp(nanoseconds: 0),
          url: URL(string: "http://e1.ru")!,
          deviceId: device,
          fileType: .mov,
          finishedAt: CKTimestamp(nanoseconds: 300)
        ),
      ]))
    }
  }

  func deleteMediaChunks(with url: URL) {
    print("Deleting \(url.path)")
  }

  func save(mediaChunk: CKMediaChunk) {
    coreDataController.backgroundContext
      .tryMap { [weak self] ctx in
        let historyEnt = HistoryEntity(context: ctx)
        historyEnt.deviceId = mediaChunk.deviceId.value
        historyEnt.fileExtension = mediaChunk.fileType.rawValue
        historyEnt.finishedAt = Int64(mediaChunk.finishedAt.nanoseconds)
        historyEnt.startedAt = Int64(mediaChunk.startedAt.nanoseconds)
        historyEnt.url = mediaChunk.url
        ctx.insert(historyEnt)
        try ctx.save()
        self?.mediaChunkSubject.send(mediaChunk)
      }
      .catch { [weak self] (error: Error) -> Empty<Void, Never> in
        self?.errorSubject.send(error)
        return Empty()
      }
      .sink {}
      .store(in: &cancellables)
  }

  private let coreDataController: CoreDataController
  private let mediaChunkSubject = PassthroughSubject<CKMediaChunk, Never>()
  private let errorSubject = PassthroughSubject<Error, Never>()
  private var cancellables = Set<AnyCancellable>()
}
