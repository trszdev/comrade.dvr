import Foundation
import CoreData

extension HistoryEntity {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryEntity> {
    NSFetchRequest<HistoryEntity>(entityName: "HistoryEntity")
  }

  @NSManaged public var url: URL
  @NSManaged public var deviceId: String
  @NSManaged public var fileExtension: String
  @NSManaged public var startedAt: Int64
  @NSManaged public var finishedAt: Int64
}

extension HistoryEntity: Identifiable {
}
