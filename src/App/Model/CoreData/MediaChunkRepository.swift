import CameraKit
import Combine
import Foundation
import CoreData

protocol MediaChunkRepository: SessionOutputSaver {
  var mediaChunkPublisher: AnyPublisher<MediaChunk, Never> { get }
  var errorPublisher: AnyPublisher<Error, Never> { get }
  func availableSelections() -> Future<[CKDeviceID: Set<Date>], Never>
  func mediaChunks(device: CKDeviceID, day: Date) -> Future<[MediaChunk], Never>
  func deleteMediaChunks(with url: URL)
}

enum MediaChunkRepositoryError: Error {
  case failedToConvertMediaChunk
}

final class MediaChunkRepositoryImpl: MediaChunkRepository {
  init(coreDataController: CoreDataController, mediaChunkConverter: MediaChunkConverter, fileManager: FileManager) {
    self.coreDataController = coreDataController
    self.mediaChunkConverter = mediaChunkConverter
    self.fileManager = fileManager
  }

  var mediaChunkPublisher: AnyPublisher<MediaChunk, Never> { mediaChunkSubject.eraseToAnyPublisher() }
  var errorPublisher: AnyPublisher<Error, Never> { errorSubject.eraseToAnyPublisher() }

  func availableSelections() -> Future<[CKDeviceID: Set<Date>], Never> {
    Future { [weak self] promise in
      guard let self = self else { return promise(.success([:])) }
      self.withBackgroundCtx { ctx in
        let deviceIds = try ctx.fetchDistinctDeviceIds()
        var result = [CKDeviceID: Set<Date>]()
        for deviceId in deviceIds {
          let fetchRequest = HistoryEntity.fetchRequest()
          fetchRequest.predicate = NSPredicate(format: "deviceId == %@", deviceId.value)
          fetchRequest.resultType = .dictionaryResultType
          fetchRequest.propertiesToFetch = ["day"]
          fetchRequest.returnsDistinctResults = true
          guard let ents = try ctx.fetch(fetchRequest) as? [[String: Date]] else { continue }
          result[deviceId] = Set(ents.compactMap { $0["day"] })
        }
        promise(.success(result))
      }
    }
  }

  func mediaChunks(device: CKDeviceID, day: Date) -> Future<[MediaChunk], Never> {
    Future { [weak self] promise in
      guard let self = self else { return promise(.success([])) }
      self.withBackgroundCtx { ctx in
        let fetchRequest = HistoryEntity.fetchRequest { request in
          request.predicate = NSPredicate(format: "deviceId == %@ AND day == %@", device.value, day as CVarArg)
        }
        let ents = try ctx.fetch(fetchRequest)
        let mediaChunks = ents.map { ent in
          MediaChunk(
            startedAt: CKTimestamp(nanoseconds: UInt64(ent.startedAt)),
            url: ent.url,
            deviceId: CKDeviceID(value: ent.deviceId),
            fileType: CKFileType(rawValue: ent.fileExtension) ?? .mov,
            finishedAt: CKTimestamp(nanoseconds: UInt64(ent.finishedAt)),
            day: ent.day
          )
        }
        promise(.success(mediaChunks))
      }
    }
  }

  func deleteMediaChunks(with url: URL) {
    withBackgroundCtx { [weak self] ctx in
      let fetchRequest = HistoryEntity.fetchRequest()
      fetchRequest.predicate = NSPredicate(format: "url == %@", url as CVarArg)
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      try ctx.execute(deleteRequest)
      try self?.fileManager.removeItem(at: url)
    }
  }

  func save(mediaChunk: CKMediaChunk, sessionStartupInfo: CKSessionStartupInfo) {
    guard let chunk = mediaChunkConverter.makeMediaChunk(from: mediaChunk, with: sessionStartupInfo) else {
      errorSubject.send(MediaChunkRepositoryError.failedToConvertMediaChunk)
      return
    }
    withBackgroundCtx { [weak self] ctx in
      let historyEnt = HistoryEntity(context: ctx)
      historyEnt.deviceId = chunk.deviceId.value
      historyEnt.fileExtension = chunk.fileType.rawValue
      historyEnt.finishedAt = Int64(chunk.finishedAt.nanoseconds)
      historyEnt.startedAt = Int64(chunk.startedAt.nanoseconds)
      historyEnt.url = chunk.url
      historyEnt.day = chunk.day
      ctx.insert(historyEnt)
      try ctx.save()
      self?.mediaChunkSubject.send(chunk)
    }
  }

  private func withBackgroundCtx(block: @escaping (NSManagedObjectContext) throws -> Void) {
    coreDataController.backgroundContext
      .tryMap(block)
      .catch { [weak self] (error: Error) -> Empty<Void, Never> in
        self?.errorSubject.send(error)
        return Empty()
      }
      .sink {}
      .store(in: &cancellables)
  }

  private let mediaChunkConverter: MediaChunkConverter
  private let coreDataController: CoreDataController
  private let fileManager: FileManager
  private let mediaChunkSubject = PassthroughSubject<MediaChunk, Never>()
  private let errorSubject = PassthroughSubject<Error, Never>()
  private var cancellables = Set<AnyCancellable>()
}

private extension NSManagedObjectContext {
  func fetchDistinctDeviceIds() throws -> Set<CKDeviceID> {
    let fetchRequest = HistoryEntity.fetchRequest()
    fetchRequest.resultType = .dictionaryResultType
    fetchRequest.propertiesToFetch = ["deviceId"]
    fetchRequest.returnsDistinctResults = true
    guard let ents = try fetch(fetchRequest) as? [[String: String]] else { return Set() }
    return Set(ents.compactMap { $0["deviceId"] }.map(CKDeviceID.init(value:)))
  }
}
