import XCTest
import CoreData
@testable import ComradeDVR

final class TestSample: XCTestCase {
  func testSample() {
    let cdModel = CoreDataControllerImpl()
    do {
      var stuff = try cdModel.context.fetch(HistoryEntity.fetchRequest())
      XCTAssert(stuff.isEmpty)
      let ent = HistoryEntity(context: cdModel.context)
      ent.url = URL(string: "/dev/null")!
      ent.deviceId = "back-camera"
      ent.fileExtension = "mov"
      ent.finishedAt = 300
      ent.startedAt = 1
      cdModel.context.insert(ent)
      try cdModel.context.save()
      stuff = try cdModel.context.fetch(HistoryEntity.fetchRequest())
      XCTAssertFalse(stuff.isEmpty)
      try cdModel.context.execute(NSBatchDeleteRequest(fetchRequest: HistoryEntity.fetchRequest()))
      try cdModel.context.save()
      stuff = try cdModel.context.fetch(HistoryEntity.fetchRequest())
      XCTAssert(stuff.isEmpty)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}
