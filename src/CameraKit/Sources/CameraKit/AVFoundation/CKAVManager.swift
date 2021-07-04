import Combine
import Dispatch
import Foundation
import AVFoundation
import AutocontainerKit

public struct CKAVManager: CKManager {
  class Builder: AKBuilder, CKManagerBuilder {
    func makeManager(infoPlistBundle: Bundle?, shouldPickNearest: Bool) -> CKManager {
      makeManager(
        permissionManager: CKAVPermissionManager(infoPlistBundle: infoPlistBundle),
        shouldPickNearest: shouldPickNearest
      )
    }

    func makeManager(mock: CKPermissionManager) -> CKManager {
      makeManager(permissionManager: mock, shouldPickNearest: true)
    }

    private func makeManager(permissionManager: CKPermissionManager, shouldPickNearest: Bool) -> CKManager {
      let manager = resolve(CKAVConfigurationManager.Builder.self).makeManager(shouldPickNearest: shouldPickNearest)
      return CKAVManager(
        permissionManager: permissionManager,
        configurationManager: manager,
        sessionMaker: resolve(CKAVSessionMaker.Builder.self)
          .makeSessionMaker(configurationPicker: manager.configurationPicker)
      )
    }
  }

  public init(
    permissionManager: CKPermissionManager,
    configurationManager: CKConfigurationManager,
    sessionMaker: CKSessionMaker
  ) {
    self.permissionManager = permissionManager
    self.configurationManager = configurationManager
    self.sessionMaker = sessionMaker
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

  public var configurationPicker: CKNearestConfigurationPicker { configurationManager.configurationPicker }
  public var adjustableConfiguration: CKAdjustableConfiguration { configurationManager.adjustableConfiguration }

  public var sessionMakerPublisher: AnyPublisher<CKSessionMaker, CKPermissionError> {
    requestPermission(for: .audio)
      .append(requestPermission(for: .video))
      .collect()
      .map { _ in sessionMaker }
      .eraseToAnyPublisher()
  }

  public static let shared: CKManager = {
    sharedContainer
      .resolve(CKManagerBuilder.self)
      .makeManager(infoPlistBundle: .main, shouldPickNearest: true)
  }()

  private static let sharedContainer = CKAVAssembly().hashContainer

  private let permissionManager: CKPermissionManager
  private let configurationManager: CKConfigurationManager
  private let sessionMaker: CKSessionMaker
}
