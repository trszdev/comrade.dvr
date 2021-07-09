import XCTest
import CoreData
import Combine
@testable import ComradeDVR

struct Expectation {
  let expectation: XCTestExpectation
  init(_ description: String? = nil, fulfillmentCount: Int = 1) {
    expectation = description.flatMap(XCTestExpectation.init(description:)) ?? XCTestExpectation()
    expectation.expectedFulfillmentCount = fulfillmentCount
    expectation.assertForOverFulfill = true
  }

  func fulfill() {
    expectation.fulfill()
  }

  func wait(timeout: TimeInterval = 5.0) {
    if case .completed = XCTWaiter().wait(for: [expectation], timeout: timeout) {
    } else {
      XCTFail("timeout exceeded")
    }
  }

  static func wait(_ amount: TimeInterval, timeout: TimeInterval = 5.0) {
    let exp = Expectation()
    DispatchQueue.main.asyncAfter(deadline: .now() + amount) {
      exp.fulfill()
    }
    exp.wait(timeout: timeout)
  }
}

final class TestCoreDataControllerImpl: XCTestCase {
  func testAlmostPersistent() {
    doSync(ctx: cdModel.viewContext) { ctx in
      let ent = self.makeHistoryEnt(ctx: ctx)
      ctx.insert(ent)
      try ctx.save()
    }
    doSync(ctx: cdModel.backgroundContext) { ctx in
      let ents = try ctx.fetch(HistoryEntity.fetchRequest())
      XCTAssert(ents.count >= 1)
    }
  }

  func testAutoMerge() {
    let expectation = Expectation()
    _ = cdModel.viewContext
      .zip(cdModel.backgroundContext)
      .catch { (error: Error) -> Empty<(NSManagedObjectContext, NSManagedObjectContext), Never> in
        XCTFail(error.localizedDescription)
        return Empty()
      }
      .sink { (viewCtx, backgroundCtx) in
        do {
          try viewCtx.execute(NSBatchDeleteRequest(fetchRequest: HistoryEntity.fetchRequest()))
          try viewCtx.save()
          let noEnts = try backgroundCtx.fetch(HistoryEntity.fetchRequest())
          XCTAssertEqual(noEnts.count, 0)
          let ent = self.makeHistoryEnt(ctx: viewCtx)
          viewCtx.insert(ent)
          try viewCtx.save()
          let ents = try backgroundCtx.fetch(HistoryEntity.fetchRequest())
          XCTAssertEqual(ents.count, 1)
        } catch {
          XCTFail(error.localizedDescription)
        }
        expectation.fulfill()
      }
    expectation.wait()
  }

  private func doSync(
    ctx: AnyPublisher<NSManagedObjectContext, Error>,
    block: @escaping (NSManagedObjectContext) throws -> Void
  ) {
    let expectation = Expectation()
    _ = ctx
      .catch { (error: Error) -> Empty<NSManagedObjectContext, Never> in
        XCTFail(error.localizedDescription)
        return Empty()
      }
      .sink { ctx in
        do {
          try block(ctx)
        } catch {
          XCTFail(error.localizedDescription)
        }
        expectation.fulfill()
      }
    expectation.wait()
  }

  private func makeHistoryEnt(ctx: NSManagedObjectContext) -> HistoryEntity {
    let ent = HistoryEntity(context: ctx)
    ent.url = URL(string: "/dev/null")!
    ent.deviceId = "back-camera"
    ent.fileExtension = "mov"
    ent.finishedAt = 300
    ent.startedAt = 1
    return ent
  }
}

let cdModel = CoreDataControllerImpl()
