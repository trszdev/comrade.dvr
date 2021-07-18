import Foundation
import CoreData

extension HistoryEntity {
  @nonobjc public class func fetchRequest(
    block: (NSFetchRequest<HistoryEntity>) -> Void
  ) -> NSFetchRequest<HistoryEntity> {
    let result = NSFetchRequest<HistoryEntity>(entityName: "HistoryEntity")
    block(result)
    return result
  }

  @NSManaged public var url: URL
  @NSManaged public var deviceId: String
  @NSManaged public var fileExtension: String
  @NSManaged public var startedAt: Int64
  @NSManaged public var finishedAt: Int64
  @NSManaged public var day: Date
}

extension HistoryEntity: Identifiable {
}
