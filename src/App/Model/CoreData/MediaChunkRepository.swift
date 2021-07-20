import CameraKit
import Combine
import Foundation
import CoreData

protocol MediaChunkRepository: SessionOutputSaver {
  var totalFileSizePublisher: AnyPublisher<FileSize?, Never> { get }
  var lastCapturePublisher: AnyPublisher<Date?, Never> { get }
  var mediaChunkPublisher: AnyPublisher<MediaChunk, Never> { get }
  var errorPublisher: AnyPublisher<Error, Never> { get }
  func availableSelections() -> Future<[CKDeviceID: Set<Date>], Never>
  func mediaChunks(device: CKDeviceID, day: Date) -> Future<[MediaChunk], Never>
  func deleteMediaChunks(with url: URL)
  func deleteAllMediaChunks()
}

enum MediaChunkRepositoryError: Error {
  case failedToConvertMediaChunk
}

final class MediaChunkRepositoryImpl: MediaChunkRepository {
  init(
    coreDataController: CoreDataController,
    mediaChunkConverter: MediaChunkConverter,
    fileManager: FileManager,
    calendar: Calendar
  ) {
    self.coreDataController = coreDataController
    self.mediaChunkConverter = mediaChunkConverter
    self.fileManager = fileManager
    self.calendar = calendar
    updateLastCapture()
    updateDirectorySize()
  }

  var lastCapturePublisher: AnyPublisher<Date?, Never> { lastCaptureSubject.eraseToAnyPublisher() }
  var totalFileSizePublisher: AnyPublisher<FileSize?, Never> { totalFileSizeSubject.eraseToAnyPublisher() }
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
    let documentsPath = fileManager.documentsDirectory.path
    return Future { [weak self] promise in
      guard let self = self else { return promise(.success([])) }
      self.withBackgroundCtx { ctx in
        let fetchRequest = HistoryEntity.fetchRequest { request in
          request.predicate = NSPredicate(format: "deviceId == %@ AND day == %@", device.value, day as CVarArg)
        }
        let ents = try ctx.fetch(fetchRequest)
        let mediaChunks = ents.map { ent in
          MediaChunk(
            startedAt: CKTimestamp(nanoseconds: UInt64(ent.startedAt)),
            url: URL(fileURLWithPath: documentsPath + ent.url.path),
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
    let path = fileManager.documentsDirectory.path + url.path
    withBackgroundCtx { [weak self] ctx in
      guard let self = self else { return }
      let fetchRequest = HistoryEntity.fetchRequest()
      fetchRequest.predicate = NSPredicate(format: "url == %@", url as CVarArg)
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      try ctx.execute(deleteRequest)
      try self.fileManager.removeItem(atPath: path)
      self.updateDirectorySize()
      self.updateLastCapture()
    }
  }

  func deleteAllMediaChunks() {
    withBackgroundCtx { [weak self] ctx in
      guard let self = self else { return }
      let fetched = try ctx.fetch(HistoryEntity.fetchRequest { _ in })
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: HistoryEntity.fetchRequest())
      try ctx.execute(deleteRequest)
      self.lastCaptureCancellable = nil
      self.lastCaptureSubject.value = nil
      for url in fetched.map(\.url) {
        do {
          let path = self.fileManager.documentsDirectory.path + url.path
          try self.fileManager.removeItem(atPath: path)
        } catch {
          print(error.localizedDescription)
        }
      }
    }
  }

  func save(mediaChunk: CKMediaChunk, sessionStartupInfo: CKSessionStartupInfo) {
    guard let chunk = mediaChunkConverter.makeMediaChunk(from: mediaChunk, with: sessionStartupInfo) else {
      errorSubject.send(MediaChunkRepositoryError.failedToConvertMediaChunk)
      return
    }
    var filePath = chunk.url.path
    filePath.removeFirst(fileManager.documentsDirectory.path.count)
    withBackgroundCtx { [weak self] ctx in
      let historyEnt = HistoryEntity(context: ctx)
      historyEnt.deviceId = chunk.deviceId.value
      historyEnt.fileExtension = chunk.fileType.rawValue
      historyEnt.finishedAt = Int64(chunk.finishedAt.nanoseconds)
      historyEnt.startedAt = Int64(chunk.startedAt.nanoseconds)
      historyEnt.url = URL(fileURLWithPath: filePath)
      historyEnt.day = chunk.day
      ctx.insert(historyEnt)
      try ctx.save()
      guard let self = self else { return }
      self.lastCaptureCancellable = nil
      let date = self.lastCapture(ent: historyEnt)
      self.updateDirectorySize()
      self.lastCaptureSubject.send(date)
      self.mediaChunkSubject.send(chunk)
    }
  }

  private func lastCapture() -> Future<Date?, Never> {
    Future { [weak self] promise in
      guard let self = self else { return promise(.success(nil)) }
      self.withBackgroundCtx { ctx in
        let fetchRequest = HistoryEntity.fetchRequest { request in
          request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(HistoryEntity.day), ascending: false),
            NSSortDescriptor(key: #keyPath(HistoryEntity.finishedAt), ascending: false),
          ]
          request.fetchLimit = 1
        }
        let ents = try ctx.fetch(fetchRequest)
        guard let ent = ents.first else { return promise(.success(nil)) }
        let date = self.lastCapture(ent: ent)
        promise(.success(date))
      }
    }
  }

  private func updateLastCapture() {
    lastCaptureCancellable = lastCapture().assignWeak(to: \.lastCaptureSubject.value, on: self)
  }

  private func updateDirectorySize() {
    totalFileSizeSubject.value = fileManager.fileSize(url: fileManager.documentsDirectory)
  }

  private func lastCapture(ent: HistoryEntity) -> Date? {
    calendar.date(
      byAdding: .nanosecond,
      value: Int(ent.finishedAt),
      to: ent.day
    )
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

  private let calendar: Calendar
  private let mediaChunkConverter: MediaChunkConverter
  private let coreDataController: CoreDataController
  private let fileManager: FileManager
  private let lastCaptureSubject = CurrentValueSubject<Date?, Never>(nil)
  private let totalFileSizeSubject = CurrentValueSubject<FileSize?, Never>(nil)
  private let mediaChunkSubject = PassthroughSubject<MediaChunk, Never>()
  private let errorSubject = PassthroughSubject<Error, Never>()
  private var cancellables = Set<AnyCancellable>()
  private var lastCaptureCancellable: AnyCancellable?
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
