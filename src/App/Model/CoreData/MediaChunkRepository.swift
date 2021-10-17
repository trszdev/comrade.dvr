import CameraKit
import Combine
import Foundation
import CoreData
import Util

protocol MediaChunkRepository: SessionOutputSaver {
  var totalFileSizePublisher: AnyPublisher<FileSize?, Never> { get }
  var lastCapturePublisher: AnyPublisher<Date?, Never> { get }
  var mediaChunkPublisher: AnyPublisher<MediaChunk, Never> { get }
  var errorPublisher: AnyPublisher<Error, Never> { get }
  var availableSelectionsPublisher: AnyPublisher<[CKDeviceID: Set<Date>], Never> { get }
  func mediaChunks(device: CKDeviceID, day: Date) -> Future<[MediaChunk], Never>
  func deleteMediaChunks(with url: URL)
  func deleteAllMediaChunks()
}

final class MediaChunkRepositoryImpl: MediaChunkRepository {
  init(
    coreDataController: CoreDataController,
    fileManager: FileManager,
    assetLimitSetting: AnySetting<AssetLimitSetting>,
    calendar: Calendar
  ) {
    self.coreDataController = coreDataController
    self.fileManager = fileManager
    self.assetLimitSetting = assetLimitSetting
    self.calendar = calendar
    assetLimitSetting.publisher
      .sink { [weak self] setting in
        self?.updateAssetLimit(setting: setting)
      }
      .store(in: &cancellables)
    updateLastCapture()
    updateDirectorySize()
    updateAssetLimit()
    updateAvailableSelections()
  }

  var lastCapturePublisher: AnyPublisher<Date?, Never> { lastCaptureSubject.eraseToAnyPublisher() }
  var totalFileSizePublisher: AnyPublisher<FileSize?, Never> { totalFileSizeSubject.eraseToAnyPublisher() }
  var mediaChunkPublisher: AnyPublisher<MediaChunk, Never> { mediaChunkSubject.eraseToAnyPublisher() }
  var errorPublisher: AnyPublisher<Error, Never> { errorSubject.eraseToAnyPublisher() }
  var availableSelectionsPublisher: AnyPublisher<[CKDeviceID: Set<Date>], Never> {
    availableSelectionsSubject.eraseToAnyPublisher()
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
    var dbPath = url.path
    var fsPath = url.path
    if url.path.starts(with: fileManager.documentsDirectory.path) {
      dbPath.removeFirst(fileManager.documentsDirectory.path.count)
    } else {
      fsPath = fileManager.documentsDirectory.path + fsPath
    }
    withBackgroundCtx { [weak self] ctx in
      guard let self = self else { return }
      try ctx.delete(url: URL(fileURLWithPath: dbPath))
      try self.fileManager.removeItem(atPath: fsPath)
      self.updateDirectorySize()
      self.updateLastCapture()
      self.updateAvailableSelections()
    }
  }

  func deleteAllMediaChunks() {
    withBackgroundCtx { [weak self] ctx in
      guard let self = self else { return }
      let deletedEnts = try ctx.deleteAll()
      self.lastCaptureCancellable = nil
      self.availableSelectionsCancellable = nil
      self.lastCaptureSubject.value = nil
      self.availableSelectionsSubject.value = [:]
      for url in deletedEnts.map(\.url) {
        do {
          let path = self.fileManager.documentsDirectory.path + url.path
          try self.fileManager.removeItem(atPath: path)
        } catch {
          print(error.localizedDescription)
        }
      }
      self.updateDirectorySize()
    }
  }

  func save(mediaChunk: CKMediaChunk, sessionStartupInfo: CKSessionStartupInfo) {
    var filePath = mediaChunk.url.path
    filePath.removeFirst(fileManager.documentsDirectory.path.count)
    let dateStarted = sessionStartupInfo.startedAt.addingTimeInterval(
      .from(nanoseconds: Double(mediaChunk.startedAt.nanoseconds))
    )
    let dateFinished = sessionStartupInfo.startedAt.addingTimeInterval(
      .from(nanoseconds: Double(mediaChunk.finishedAt.nanoseconds))
    )
    let day = calendar.startOfDay(for: dateStarted)
    let startedAt = dateStarted.timeIntervalSince(day)
    let finishedAt = dateFinished.timeIntervalSince(day)
    withBackgroundCtx { [weak self] ctx in
      let historyEnt = HistoryEntity(context: ctx)
      historyEnt.deviceId = mediaChunk.deviceId.value
      historyEnt.fileExtension = mediaChunk.fileType.rawValue
      historyEnt.finishedAt = Int64(finishedAt.nanoseconds)
      historyEnt.startedAt = Int64(startedAt.nanoseconds)
      historyEnt.url = URL(fileURLWithPath: filePath)
      historyEnt.day = day
      ctx.insert(historyEnt)
      try ctx.save()
      guard let self = self else { return }
      self.lastCaptureCancellable = nil
      let date = self.lastCapture(ent: historyEnt)
      self.updateDirectorySize()
      self.lastCaptureSubject.send(date)
      let mediaChunk = MediaChunk(
        startedAt: CKTimestamp(nanoseconds: UInt64(startedAt.nanoseconds)),
        url: mediaChunk.url,
        deviceId: mediaChunk.deviceId,
        fileType: mediaChunk.fileType,
        finishedAt: CKTimestamp(nanoseconds: UInt64(finishedAt.nanoseconds)),
        day: day
      )
      self.mediaChunkSubject.send(mediaChunk)
      self.updateAvailableSelections()
      self.updateAssetLimit()
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

  private func updateAssetLimit(setting: AssetLimitSetting? = nil) {
    guard let limitSize = setting?.value ?? assetLimitSetting.value.value,
      let totalSize = fileManager.fileSize(url: fileManager.documentsDirectory),
      limitSize < totalSize
    else {
      return
    }
    assetLimitCancellable = coreDataController.backgroundContext
      .tryMap { [weak self] ctx in
        guard let self = self, let deletedEnt = try ctx.deleteLatest() else { return }
        let path = self.fileManager.documentsDirectory.path + deletedEnt.url.path
        try self.fileManager.removeItem(atPath: path)
        self.updateDirectorySize()
        self.updateAssetLimit()
      }
      .catch { [weak self] (error: Error) -> Empty<Void, Never> in
        self?.errorSubject.send(error)
        return Empty()
      }
      .sink {}
  }

  private func availableSelections() -> Future<[CKDeviceID: Set<Date>], Never> {
    Future { [weak self] promise in
      guard let self = self else { return promise(.success([:])) }
      self.withBackgroundCtx { ctx in
        let deviceIds = try ctx.fetchDistinctDeviceIds()
        var result = [CKDeviceID: Set<Date>]()
        for deviceId in deviceIds {
          guard let dates = try ctx.fetchDates(deviceId: deviceId) else { continue }
          result[deviceId] = dates
        }
        promise(.success(result))
      }
    }
  }

  private func updateAvailableSelections() {
    availableSelectionsCancellable = availableSelections().sink { [weak self] selections in
      self?.availableSelectionsSubject.send(selections)
    }
  }

  private func updateLastCapture() {
    lastCaptureCancellable = lastCapture().assignWeak(to: \.lastCaptureSubject.value, on: self)
  }

  private func updateDirectorySize() {
    totalFileSizeSubject.value = fileManager.fileSize(url: fileManager.documentsDirectory)
  }

  private func lastCapture(ent: HistoryEntity) -> Date? {
    ent.day.addingTimeInterval(.from(nanoseconds: Double(ent.finishedAt)))
  }

  private func withBackgroundCtx(block: @escaping (NSManagedObjectContext) throws -> Void) {
    coreDataController.backgroundContext
      .tryMap(block)
      .catch { [weak self] (error: Error) -> Empty<Void, Never> in
        self?.errorSubject.send(error)
        print(error.localizedDescription)
        return Empty()
      }
      .sink {}
      .store(in: &cancellables)
  }

  private let availableSelectionsSubject = CurrentValueSubject<[CKDeviceID: Set<Date>], Never>([:])
  private var assetLimitCancellable: AnyCancellable?
  private var availableSelectionsCancellable: AnyCancellable?
  private let assetLimitSetting: AnySetting<AssetLimitSetting>
  private let calendar: Calendar
  private let coreDataController: CoreDataController
  private let fileManager: FileManager
  private let lastCaptureSubject = CurrentValueSubject<Date?, Never>(nil)
  private let totalFileSizeSubject = CurrentValueSubject<FileSize?, Never>(nil)
  private let mediaChunkSubject = PassthroughSubject<MediaChunk, Never>()
  private let errorSubject = PassthroughSubject<Error, Never>()
  private var cancellables = Set<AnyCancellable>()
  private var lastCaptureCancellable: AnyCancellable?
}
