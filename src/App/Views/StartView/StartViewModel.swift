import SwiftUI
import Combine
import CameraKit

protocol StartViewModel: ObservableObject {
  var devices: [StartViewModelDevice] { get }
  var devicesPublished: Published<[StartViewModelDevice]> { get }
  var devicesPublisher: Published<[StartViewModelDevice]>.Publisher { get }

  func presentConfigureDeviceScreen(for device: StartViewModelDevice)
  func start()
  func openSettingsUrl()
  var errors: AnyPublisher<Error, Never> { get }

  var sessionStatus: SessionStatus? { get }
  var sessionStatusPublished: Published<SessionStatus?> { get }
  var sessionStatusPublisher: Published<SessionStatus?>.Publisher { get }
}

struct StartViewModelBuilder {
  let devicesModel: DevicesModel
  let configureMicrophoneViewBuilder: ConfigureMicrophoneViewBuilder
  let configureCameraViewBuilder: ConfigureCameraViewBuilder
  let appLocaleModel: AppLocaleModel
  let navigationViewPresenter: NavigationViewPresenter
  let app: UIApplication
  let sessionController: SessionController

  func makeViewModel() -> StartViewModelImpl {
    StartViewModelImpl(
      devicesModel: devicesModel,
      configureMicrophoneViewBuilder: configureMicrophoneViewBuilder,
      configureCameraViewBuilder: configureCameraViewBuilder,
      appLocaleModel: appLocaleModel,
      navigationViewPresenter: navigationViewPresenter,
      app: app,
      sessionController: sessionController
    )
  }
}

final class StartViewModelImpl: StartViewModel {
  init(
    devicesModel: DevicesModel,
    configureMicrophoneViewBuilder: ConfigureMicrophoneViewBuilder,
    configureCameraViewBuilder: ConfigureCameraViewBuilder,
    appLocaleModel: AppLocaleModel,
    navigationViewPresenter: NavigationViewPresenter,
    app: UIApplication,
    sessionController: SessionController
  ) {
    self.devicesModel = devicesModel
    self.configureMicrophoneViewBuilder = configureMicrophoneViewBuilder
    self.configureCameraViewBuilder = configureCameraViewBuilder
    self.navigationViewPresenter = navigationViewPresenter
    self.app = app
    self.sessionController = sessionController
    self.appLocaleModel = appLocaleModel
    self.sessionStatusInternal = sessionController.status
    setup()
  }

  @Published private(set) var devices = [StartViewModelDevice]()
  var devicesPublished: Published<[StartViewModelDevice]> { _devices }
  var devicesPublisher: Published<[StartViewModelDevice]>.Publisher { $devices }

  func presentConfigureDeviceScreen(for device: StartViewModelDevice) {
    guard let device = devicesModel.device(id: device.id) else { return }
    switch device {
    case let .camera(cameraDevice):
      let viewModel = ConfigureCameraViewModelImpl(devicesModel: devicesModel, cameraDevice: cameraDevice)
      let view = configureCameraViewBuilder.makeView(viewModel: viewModel)
      navigationViewPresenter.presentView {
        view
      }
    case let .microphone(microphoneDevice):
      let viewModel = ConfigureMicrophoneViewModelImpl(devicesModel: devicesModel, microphoneDevice: microphoneDevice)
      let view = configureMicrophoneViewBuilder.makeView(viewModel: viewModel)
      navigationViewPresenter.presentView {
        view
      }
    }
  }

  func start() {
    sessionController.tryStart()
  }

  func openSettingsUrl() {
    guard let url = URL(string: UIApplication.openSettingsURLString), app.canOpenURL(url) else { return }
    app.open(url, options: [:], completionHandler: nil)
  }

  var errors: AnyPublisher<Error, Never> {
    errorSubject.eraseToAnyPublisher()
  }

  @Published private(set) var sessionStatus: SessionStatus? = .notRunning
  var sessionStatusPublished: Published<SessionStatus?> { _sessionStatus }
  var sessionStatusPublisher: Published<SessionStatus?>.Publisher { $sessionStatus }

  private func setup() {
    received(devices: devicesModel.devices)
    received(status: sessionController.status)
    sessionController.statusPublisher
      .receive(on: DispatchQueue.main)
      .map { [weak self] status in
        self?.received(status: status)
      }
      .catch { [weak self] (error: Error) -> Empty<Void, Never> in
        self?.errorSubject.send(error)
        return Empty()
      }
      .sink {}
      .store(in: &cancellables)
    devicesModel.devicesPublisher
      .sink { [weak self] devices in self?.received(devices: devices) }
      .store(in: &cancellables)
    appLocaleModel.appLocalePublisher
      .sink { [weak self] appLocale in self?.received(appLocale: appLocale) }
      .store(in: &cancellables)
  }

  private func received(status: SessionStatus?) {
    if let status = status {
      sessionStatusInternal = status
    }
    sessionStatus = devices.contains(where: \.isActive) ? sessionStatusInternal : nil
  }

  private func received(devices: [Device]? = nil, appLocale: AppLocale? = nil) {
    self.devices = (devices ?? devicesModel.devices).map {
      StartViewModelDevice.from(device: $0, appLocale: appLocale ?? appLocaleModel.appLocale)
    }
    received(status: nil)
  }

  private var sessionStatusInternal: SessionStatus
  private let errorSubject = PassthroughSubject<Error, Never>()
  private var cancellables = Set<AnyCancellable>()
  private let devicesModel: DevicesModel
  private let configureMicrophoneViewBuilder: ConfigureMicrophoneViewBuilder
  private let configureCameraViewBuilder: ConfigureCameraViewBuilder
  private let navigationViewPresenter: NavigationViewPresenter
  private let app: UIApplication
  private let sessionController: SessionController
  private let appLocaleModel: AppLocaleModel
}
