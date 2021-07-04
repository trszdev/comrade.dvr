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

  var isStartButtonBusy: Bool { get }
  var isStartButtonBusyPublished: Published<Bool> { get }
  var isStartButtonBusyPublisher: Published<Bool>.Publisher { get }
}

struct StartViewModelBuilder {
  let devicesModel: DevicesModel
  let configureMicrophoneViewBuilder: ConfigureMicrophoneViewBuilder
  let configureCameraViewBuilder: ConfigureCameraViewBuilder
  let appLocaleModel: AppLocaleModel
  let navigationViewPresenter: NavigationViewPresenter
  let app: UIApplication
  let sessionModel: SessionStarter

  func makeViewModel() -> StartViewModelImpl {
    StartViewModelImpl(
      devicesModel: devicesModel,
      configureMicrophoneViewBuilder: configureMicrophoneViewBuilder,
      configureCameraViewBuilder: configureCameraViewBuilder,
      appLocaleModel: appLocaleModel,
      navigationViewPresenter: navigationViewPresenter,
      app: app,
      sessionModel: sessionModel
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
    sessionModel: SessionStarter
  ) {
    self.devices = devicesModel.devices.map {
      StartViewModelDevice.from(device: $0, appLocale: appLocaleModel.appLocale)
    }
    self.devicesModel = devicesModel
    self.configureMicrophoneViewBuilder = configureMicrophoneViewBuilder
    self.configureCameraViewBuilder = configureCameraViewBuilder
    self.navigationViewPresenter = navigationViewPresenter
    self.app = app
    self.sessionModel = sessionModel
    devicesModel.devicesPublisher
      .map { devices in devices.map { StartViewModelDevice.from(device: $0, appLocale: appLocaleModel.appLocale) } }
      .assignWeak(to: \.devices, on: self)
      .store(in: &cancellables)
    appLocaleModel.appLocalePublisher
      .map { appLocale in devicesModel.devices.map { StartViewModelDevice.from(device: $0, appLocale: appLocale) } }
      .assignWeak(to: \.devices, on: self)
      .store(in: &cancellables)
  }

  @Published private(set) var devices: [StartViewModelDevice]
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
    isStartButtonBusy = true
    sessionModel.startSession()
      .receive(on: DispatchQueue.main)
      .catch { [weak self] (error: Error) -> Empty<Void, Never> in
        if let self = self {
          self.errorSubject.send(error)
          self.isStartButtonBusy = false
        }
        return Empty()
      }
      .sink { [weak self] in
        self?.isStartButtonBusy = false
      }
      .store(in: &cancellables)
  }

  func openSettingsUrl() {
    guard let url = URL(string: UIApplication.openSettingsURLString), app.canOpenURL(url) else { return }
    app.open(url, options: [:], completionHandler: nil)
  }

  var errors: AnyPublisher<Error, Never> {
    errorSubject.eraseToAnyPublisher()
  }

  @Published private(set) var isStartButtonBusy: Bool = false
  var isStartButtonBusyPublished: Published<Bool> { _isStartButtonBusy }
  var isStartButtonBusyPublisher: Published<Bool>.Publisher { $isStartButtonBusy }

  private let errorSubject = PassthroughSubject<Error, Never>()
  private var cancellables = Set<AnyCancellable>()
  private let devicesModel: DevicesModel
  private let configureMicrophoneViewBuilder: ConfigureMicrophoneViewBuilder
  private let configureCameraViewBuilder: ConfigureCameraViewBuilder
  private let navigationViewPresenter: NavigationViewPresenter
  private let app: UIApplication
  private let sessionModel: SessionStarter
}
