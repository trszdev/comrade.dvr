import Combine
import CameraKit
import Foundation
import UIKit

protocol SessionStarter {
  func startSession() -> AnyPublisher<Void, Error>
}

final class SessionStarterImpl: SessionStarter {
  init(
    ckManager: CKManager,
    devicesModel: DevicesModel,
    orientationSetting: AnySetting<OrientationSetting>,
    sessionViewControllerBuilder: SessionViewController.Builder,
    application: UIApplication,
    sessionViewBuilder: SessionViewBuilder,
    sessionViewModelBuilder: SessionViewModelBuilder,
    rootViewModelBuilder: RootViewModelBuilder
  ) {
    self.ckManager = ckManager
    self.devicesModel = devicesModel
    self.orientationSetting = orientationSetting
    self.sessionViewControllerBuilder = sessionViewControllerBuilder
    self.application = application
    self.sessionViewBuilder = sessionViewBuilder
    self.sessionViewModelBuilder = sessionViewModelBuilder
    self.rootViewModelBuilder = rootViewModelBuilder
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

  private func makeSessionVc(
    session: CKSession,
    orientation: CKOrientation,
    devices: [Device]
  ) -> SessionViewController {
    let viewModel = sessionViewModelBuilder.makeViewModel(session: session, devices: devices)
    let sessionView = sessionViewBuilder.makeView(viewModel: viewModel, orientation: orientation)
    let rootViewModel = rootViewModelBuilder.makeViewModel()
    let rootView = RootView(viewModel: rootViewModel, content: { sessionView }).eraseToAnyView()
    let sessionVc = sessionViewControllerBuilder.makeViewController(orientation: orientation, rootView: rootView)
    viewModel.sessionViewController = sessionVc
    return sessionVc
  }

  private func makeSessionPublisher() -> AnyPublisher<Void, Error> {
    let orientation = ckOrientatsion(orientationSetting.value)
    let devices = devicesModel.devices
    return ckManager.sessionMakerPublisher
      .tryCompactMap { [weak self] sessionMaker in
        guard let self = self else { return nil }
        return try sessionMaker.makeSession(configuration: self.configuration(orientation))
      }
      .compactMap { [weak self] (session: CKSession) -> SessionViewController? in
        guard let self = self else { return nil }
        return self.makeSessionVc(session: session, orientation: orientation, devices: devices)
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
  private let sessionViewBuilder: SessionViewBuilder
  private let sessionViewModelBuilder: SessionViewModelBuilder
  private let rootViewModelBuilder: RootViewModelBuilder
}
