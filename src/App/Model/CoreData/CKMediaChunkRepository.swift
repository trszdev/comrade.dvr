import CameraKit
import Combine

protocol CKMediaChunkRepository: SessionOutputSaver {
}

final class CKMediaChunkRepositoryImpl: CKMediaChunkRepository {
  init(coreDataController: CoreDataController) {
    self.coreDataController = coreDataController
  }

  func save(mediaChunk: CKMediaChunk) {
    coreDataController.backgroundContext
      .tryMap { ctx in
        let historyEnt = HistoryEntity(context: ctx)
        historyEnt.deviceId = mediaChunk.deviceId.value
        historyEnt.fileExtension = mediaChunk.fileType.rawValue
        historyEnt.finishedAt = Int64(mediaChunk.finishedAt.nanoseconds)
        historyEnt.startedAt = Int64(mediaChunk.startedAt.nanoseconds)
        historyEnt.url = mediaChunk.url
        ctx.insert(historyEnt)
        try ctx.save()
      }
      .mapError { (error: Error) -> Error in
        print(error.localizedDescription)
        return error
      }
      .catch { _ in Empty() }
      .sink {}
      .store(in: &cancellables)
  }

  private let coreDataController: CoreDataController
  private var cancellables = Set<AnyCancellable>()
}
