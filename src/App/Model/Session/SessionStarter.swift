import Combine
import CameraKit
import Foundation
import UIKit

protocol SessionStarter {
  func startSession() -> AnyPublisher<Void, Error>
}

class SessionStarterImpl: SessionStarter {
  init(
    ckManager: CKManager,
    devicesModel: DevicesModel,
    orientationSetting: AnySetting<OrientationSetting>,
    sessionViewControllerBuilder: SessionViewController.Builder,
    application: UIApplication
  ) {
    self.ckManager = ckManager
    self.devicesModel = devicesModel
    self.orientationSetting = orientationSetting
    self.sessionViewControllerBuilder = sessionViewControllerBuilder
    self.application = application
    self.startSessionPublisher = startSessionSubject
      .debounce(for: 0.5, scheduler: RunLoop.main)
      .removeDuplicates { _, _ in true }
      .flatMap(makeSessionPublisher)
      .eraseToAnyPublisher()
  }

  func startSession() -> AnyPublisher<Void, Error> {
    DispatchQueue.main.async(execute: startSessionSubject.send)
    return startSessionPublisher
  }

  private func configuration(_ orientation: CKOrientation) -> CKConfiguration {
    devicesModel.devices.configuration(orientation: orientation)
  }

  private func ckOrientatsion(_ orientation: OrientationSetting) -> CKOrientation {
    let interfaceOrientation = application.windows.first?.windowScene?.interfaceOrientation ?? .portrait
    switch orientation {
    case .portrait:
      return .portrait
    case .landscape:
      return interfaceOrientation == .landscapeLeft ? .landscapeLeft : .landscapeRight
    case .system:
      switch interfaceOrientation {
      case .landscapeLeft:
        return .landscapeLeft
      case .landscapeRight:
        return .landscapeRight
      case .portraitUpsideDown:
        return .portraitUpsideDown
      default:
        return .portrait
      }
    }
  }

  private func makeSessionPublisher() -> AnyPublisher<Void, Error> {
    let orientation = ckOrientatsion(orientationSetting.value)
    return ckManager.sessionMakerPublisher
      .tryMap { [configuration] (sessionMaker: CKSessionMaker) -> CKSession in
        try sessionMaker.makeSession(configuration: configuration(orientation))
      }
      .map { [sessionViewControllerBuilder] session in
        sessionViewControllerBuilder
          .makeViewController(orientation: orientation, session: session)
      }
      .receive(on: DispatchQueue.main)
      .flatMap { sessionViewController in
        Deferred {
          sessionViewController.present()
        }
      }
      .eraseToAnyPublisher()
  }

  private var startSessionSubject = PassthroughSubject<Void, Never>()
  private var startSessionPublisher: AnyPublisher<Void, Error>!
  private let ckManager: CKManager
  private let devicesModel: DevicesModel
  private let orientationSetting: AnySetting<OrientationSetting>
  private let sessionViewControllerBuilder: SessionViewController.Builder
  private let application: UIApplication
}
