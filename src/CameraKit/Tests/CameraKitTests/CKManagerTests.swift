import XCTest
import Combine
import Foundation
@testable import CameraKit

class CKManagerTests: CKTestCase {
  override var isAbstractTestCase: Bool { true }

  func testRequestPermission_endsWithAnyResult() {
    testRequestPermission_endsWithAnyResult(mediaType: .audio)
    testRequestPermission_endsWithAnyResult(mediaType: .video)
  }

  func testCheckPermission_endsWithAnyResult() {
    testCheckPermission_endsWithAnyResult(mediaType: .audio)
    testCheckPermission_endsWithAnyResult(mediaType: .video)
  }

  func testGeneralMemoryLeak() {
    let mock = CKPermissionManagerMock()
    let manager = makeManager(mock: mock)
    let expectation = Expectation()
    weak var session: CKSession?
    manager.sessionMakerPublisher
      .tryMap { sessionMaker in try sessionMaker.makeSession(configuration: .empty) }
      .map { createdSession in
        session = createdSession
        expectation.fulfill()
      }
      .catch { (error: Error) -> Just<Void> in
        XCTFail(error.localizedDescription)
        expectation.fulfill()
        return Just(())
      }
      .sink {}
      .store(in: &cancellables)
    expectation.wait()
    XCTAssert(session == nil)
  }

  func testSessionMaker_okIfNoPermissionProblems() {
    let mock = CKPermissionManagerMock()
    let manager = makeManager(mock: mock)
    let expectation = Expectation()
    manager.sessionMakerPublisher
      .sink(receiveCompletion: { _ in
      }, receiveValue: { _ in
        expectation.fulfill()
      })
      .store(in: &cancellables)
    expectation.wait()
    XCTAssertEqual(mock.calls.for(.permissionStatus), 2)
    XCTAssertEqual(mock.calls.for(.requestPermission), 2)
  }

  func testSessionMaker_failsOnAnyPermissionProblem() {
    let mock = CKPermissionManagerMock()
    mock.requestedPermissions = [.audio: .noDescription(mediaType: .audio)]
    let manager = makeManager(mock: mock)
    let expectation = Expectation()
    manager.sessionMakerPublisher
      .sink(receiveCompletion: { completion in
        guard case .failure(.noDescription(.audio)) = completion else { return }
        expectation.fulfill()
      }, receiveValue: { _ in
      })
      .store(in: &cancellables)
    expectation.wait()
  }

  func testSessionMaker_dontRequestExistingPermissions() {
    let mock = CKPermissionManagerMock()
    mock.permissionStatuses = [.audio: true, .video: false]
    let manager = makeManager(mock: mock)
    let expectation = Expectation()
    manager.sessionMakerPublisher
      .sink(receiveCompletion: { completion in
        guard case .failure(.noPermission(mediaType: .video)) = completion else { return }
        expectation.fulfill()
      }, receiveValue: { _ in
      })
      .store(in: &cancellables)
    expectation.wait()
    XCTAssertEqual(mock.calls.for(.permissionStatus), 2)
    XCTAssertEqual(mock.calls.for(.requestPermission), 0)
  }

  private func testCheckPermission_endsWithAnyResult(mediaType: CKMediaType) {
    let manager = makeManager()
    let expectation = Expectation()
    manager.permissionStatus(for: mediaType)
      .sink(receiveCompletion: { _ in
      }, receiveValue: { _ in
        expectation.fulfill()
      })
      .store(in: &cancellables)
    expectation.wait()
  }

  private func testRequestPermission_endsWithAnyResult(mediaType: CKMediaType) {
    let manager = makeManager()
    let expectation = Expectation()
    manager.requestPermission(for: mediaType)
      .sink(receiveCompletion: { completion in
        if case .failure(.noDescription(mediaType)) = completion {
          return
        }
        expectation.fulfill()
      }, receiveValue: {
      })
      .store(in: &cancellables)
    expectation.wait()
  }

  open func makeManager() -> CKManager {
    notImplemented()
  }

  open func makeManager(mock: CKPermissionManager) -> CKManager {
    notImplemented()
  }

  private var cancellables = Set<AnyCancellable>()
}

private final class CKPermissionManagerMock: CKPermissionManager {
  enum Table {
    case permissionStatus
    case requestPermission
  }

  let calls = CallLogger(Table.self)
  var permissionStatuses = [CKMediaType: Bool]()
  var requestedPermissions = [CKMediaType: CKPermissionError]()

  func permissionStatus(for mediaType: CKMediaType) -> AnyPublisher<Bool?, Never> {
    calls.log(.permissionStatus)
    return Just(permissionStatuses[mediaType]).setFailureType(to: Never.self).eraseToAnyPublisher()
  }

  func requestPermission(for mediaType: CKMediaType) -> AnyPublisher<Void, CKPermissionError> {
    calls.log(.requestPermission)
    return requestedPermissions[mediaType].flatMap { Fail(outputType: Void.self, failure: $0).eraseToAnyPublisher() } ??
      Just(()).setFailureType(to: CKPermissionError.self).eraseToAnyPublisher()
  }
}
