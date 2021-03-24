import XCTest
import Combine
import Foundation
@testable import CameraKit

final class CKManagerTests: CKTestCase {
  func testRequestPermission_endsWithAnyResult() {
    testRequestPermission_endsWithAnyResult(mediaType: .audio)
    testRequestPermission_endsWithAnyResult(mediaType: .video)
  }

  func testCheckPermission_endsWithAnyResult() {
    testCheckPermission_endsWithAnyResult(mediaType: .audio)
    testCheckPermission_endsWithAnyResult(mediaType: .video)
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
    XCTAssertEqual(mock.permissionStatusCalls, 2)
    XCTAssertEqual(mock.requestPermissionCalls, 2)
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
    XCTAssertEqual(mock.permissionStatusCalls, 2)
    XCTAssertEqual(mock.requestPermissionCalls, 0)
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

  private func makeManager() -> CKManager {
    avLocator.resolve(CKAVManager.Builder.self).makeManager(infoPlistBundle: nil)
  }

  private func makeManager(mock: CKPermissionManager) -> CKManager {
    CKAVManager(permissionManager: mock, locator: avLocator)
  }

  private var cancellables = Set<AnyCancellable>()
}

private final class CKPermissionManagerMock: CKPermissionManager {
  var permissionStatuses = [CKMediaType: Bool]()
  var requestedPermissions = [CKMediaType: CKPermissionError]()
  var requestPermissionCalls = 0
  var permissionStatusCalls = 0

  func permissionStatus(for mediaType: CKMediaType) -> AnyPublisher<Bool?, Never> {
    permissionStatusCalls += 1
    return Just(permissionStatuses[mediaType]).setFailureType(to: Never.self).eraseToAnyPublisher()
  }

  func requestPermission(for mediaType: CKMediaType) -> AnyPublisher<Void, CKPermissionError> {
    requestPermissionCalls += 1
    return requestedPermissions[mediaType].flatMap { Fail(outputType: Void.self, failure: $0).eraseToAnyPublisher() } ??
      Just(()).setFailureType(to: CKPermissionError.self).eraseToAnyPublisher()
  }
}
