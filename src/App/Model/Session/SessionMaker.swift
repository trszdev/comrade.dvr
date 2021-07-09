import CameraKit
import Combine
import UIKit
import AutocontainerKit

protocol SessionMaker {
  func makeSession() -> AnyPublisher<(CKSession, SessionViewController), Error>
}

final class SessionMakerImpl: SessionMaker {
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
  }

  func makeSession() -> AnyPublisher<(CKSession, SessionViewController), Error> {
    let orientation = ckOrientation(orientationSetting.value)
    let devices = devicesModel.devices
    return ckManager.sessionMakerPublisher
      .delay(for: 0.5, scheduler: DispatchQueue.main) // TODO: fix CameraKit executing thread
      .tryCompactMap { [weak self] sessionMaker in
        guard let self = self else { return nil }
        return try sessionMaker.makeSession(configuration: self.configuration(orientation))
      }
      .compactMap { [weak self] (session: CKSession) -> (CKSession, SessionViewController)? in
        self?.makeSessionVc(session: session, orientation: orientation, devices: devices)
      }
      .eraseToAnyPublisher()
  }

  private func configuration(_ orientation: CKOrientation) -> CKConfiguration {
    devicesModel.devices.configuration(orientation: orientation)
  }

  private func ckOrientation(_ orientation: OrientationSetting) -> CKOrientation {
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
  ) -> (CKSession, SessionViewController) {
    let viewModel = sessionViewModelBuilder.makeViewModel(session: session, devices: devices)
    let sessionView = sessionViewBuilder.makeView(viewModel: viewModel, orientation: orientation)
    let rootViewModel = rootViewModelBuilder.makeViewModel()
    let rootView = RootView(viewModel: rootViewModel, content: { sessionView }).eraseToAnyView()
    let sessionVc = sessionViewControllerBuilder.makeViewController(orientation: orientation, rootView: rootView)
    return (session, sessionVc)
  }

  private let ckManager: CKManager
  private let devicesModel: DevicesModel
  private let orientationSetting: AnySetting<OrientationSetting>
  private let sessionViewControllerBuilder: SessionViewController.Builder
  private let application: UIApplication
  private let sessionViewBuilder: SessionViewBuilder
  private let sessionViewModelBuilder: SessionViewModelBuilder
  private let rootViewModelBuilder: RootViewModelBuilder
}
