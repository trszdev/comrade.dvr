import CoreData
import CameraKit

extension NSManagedObjectContext {
  func fetchDistinctDeviceIds() throws -> Set<CKDeviceID> {
    let fetchRequest = HistoryEntity.fetchRequest()
    fetchRequest.resultType = .dictionaryResultType
    fetchRequest.propertiesToFetch = ["deviceId"]
    fetchRequest.returnsDistinctResults = true
    guard let ents = try fetch(fetchRequest) as? [[String: String]] else { return Set() }
    return Set(ents.compactMap { $0["deviceId"] }.map(CKDeviceID.init(value:)))
  }

  func fetchDates(deviceId: CKDeviceID) throws -> Set<Date>? {
    let fetchRequest = HistoryEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "deviceId == %@", deviceId.value)
    fetchRequest.resultType = .dictionaryResultType
    fetchRequest.propertiesToFetch = ["day"]
    fetchRequest.returnsDistinctResults = true
    guard let ents = try fetch(fetchRequest) as? [[String: Date]] else { return nil }
    return Set(ents.compactMap { $0["day"] })
  }

  func deleteLatest() throws -> HistoryEntity? {
    let fetchRequest = HistoryEntity.fetchRequest { request in
      request.sortDescriptors = [
        NSSortDescriptor(key: #keyPath(HistoryEntity.day), ascending: true),
        NSSortDescriptor(key: #keyPath(HistoryEntity.startedAt), ascending: true),
      ]
      request.fetchLimit = 2
    }
    let ents = try fetch(fetchRequest)
    guard ents.count == 2 else { return nil }
    let entToDelete = ents[0]
    delete(entToDelete)
    try save()
    return entToDelete
  }

  func deleteAll() throws -> [HistoryEntity] {
    let fetched = try fetch(HistoryEntity.fetchRequest { _ in })
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: HistoryEntity.fetchRequest())
    try execute(deleteRequest)
    try save()
    return fetched
  }

  func delete(url: URL) throws {
    let fetchRequest = HistoryEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "url == %@", url as CVarArg)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    try execute(deleteRequest)
    try save()
  }
}
