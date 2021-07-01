import Combine
import CameraKit
import Foundation

protocol SessionStarter {
  func startSession() -> AnyPublisher<Void, Error>
}

class SessionStarterImpl: SessionStarter {
  init(
    ckManager: CKManager,
    devicesModel: DevicesModel,
    orientationSetting: AnySetting<OrientationSetting>,
    sessionViewControllerBuilder: SessionViewController.Builder
  ) {
    self.ckManager = ckManager
    self.devicesModel = devicesModel
    self.orientationSetting = orientationSetting
    self.sessionViewControllerBuilder = sessionViewControllerBuilder
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

  private func makeSessionPublisher() -> AnyPublisher<Void, Error> {
    ckManager.sessionMakerPublisher
      .tryMap { [devicesModel] (sessionMaker: CKSessionMaker) -> CKSession in
        try sessionMaker.makeSession(configuration: devicesModel.devices.configuration)
      }
      .map { [sessionViewControllerBuilder, orientationSetting] session in
        sessionViewControllerBuilder
          .makeViewController(orientation: orientationSetting.value, session: session)
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
}
