import Combine
import Dispatch
import Foundation
import AVFoundation
import AutocontainerKit

public final class CKAVManager: CKManager {
  public struct Builder {
    public let locator: AKLocator

    public init(locator: AKLocator) {
      self.locator = locator
    }

    func makeManager(infoPlistBundle: Bundle?) -> CKAVManager {
      CKAVManager(permissionManager: CKAVPermissionManager(infoPlistBundle: infoPlistBundle), locator: locator)
    }
  }

  public init(permissionManager: CKPermissionManager, locator: AKLocator) {
    self.permissionManager = permissionManager
    self.locator = locator
  }

  public func permissionStatus(for mediaType: CKMediaType) -> AnyPublisher<Bool?, Never> {
    permissionManager.permissionStatus(for: mediaType)
  }

  public func requestPermission(for mediaType: CKMediaType) -> AnyPublisher<Void, CKPermissionError> {
    permissionStatus(for: mediaType)
      .setFailureType(to: CKPermissionError.self)
      .flatMap { (granted: Bool?) -> AnyPublisher<Void, CKPermissionError> in
        guard let granted = granted else {
          return self.permissionManager.requestPermission(for: mediaType).eraseToAnyPublisher()
        }
        return granted ?
          Just(()).setFailureType(to: CKPermissionError.self).eraseToAnyPublisher() :
          Fail(outputType: Void.self, failure: .noPermission(mediaType: mediaType)).eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
  }

  public var sessionMakerPublisher: AnyPublisher<CKSessionMaker, CKPermissionError> {
    requestPermission(for: .audio)
      .append(requestPermission(for: .video))
      .collect()
      .map { _ in self.locator.resolve(CKSessionMaker.self) }
      .eraseToAnyPublisher()
  }

  public static let shared: CKAVManager = {
    CKAVAssembly().hashContainer.resolve(Builder.self).makeManager(infoPlistBundle: .main)
  }()

  private let permissionManager: CKPermissionManager
  private let locator: AKLocator
}
