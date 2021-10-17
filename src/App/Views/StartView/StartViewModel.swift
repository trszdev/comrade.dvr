import SwiftUI
import Combine
import CameraKit
import AutocontainerKit
import Util

protocol StartViewModel: ObservableObject {
  var devices: [StartViewModelDevice] { get }
  var devicesPublished: Published<[StartViewModelDevice]> { get }
  var devicesPublisher: Published<[StartViewModelDevice]>.Publisher { get }

  var usedSpace: FileSize? { get }
  var usedSpacePublished: Published<FileSize?> { get }
  var usedSpacePublisher: Published<FileSize?>.Publisher { get }

  var spaceLimit: FileSize? { get }
  var spaceLimitPublished: Published<FileSize?> { get }
  var spaceLimitPublisher: Published<FileSize?>.Publisher { get }

  var lastCapture: Date? { get }
  var lastCapturePublished: Published<Date?> { get }
  var lastCapturePublisher: Published<Date?>.Publisher { get }

  func presentConfigureDeviceScreen(for device: StartViewModelDevice)
  func start()
  func openSettingsUrl()
  var errors: AnyPublisher<Error, Never> { get }

  var sessionStatus: SessionStatus? { get }
  var sessionStatusPublished: Published<SessionStatus?> { get }
  var sessionStatusPublisher: Published<SessionStatus?>.Publisher { get }
}

final class StartViewModelBuilder: AKBuilder {
  func makeViewModel() -> StartViewModelImpl {
    StartViewModelImpl(
      devicesModel: resolve(DevicesModel.self),
      configureMicrophoneViewBuilder: resolve(ConfigureMicrophoneViewBuilder.self),
      configureCameraViewBuilder: resolve(ConfigureCameraViewBuilder.self),
      appLocaleModel: resolve(AppLocaleModel.self),
      navigationViewPresenter: resolve(NavigationViewPresenter.self),
      app: resolve(UIApplication.self),
      sessionController: resolve(SessionController.self),
      mediaChunkRepository: resolve(MediaChunkRepository.self),
      assetLimitSetting: resolve(AnySetting<AssetLimitSetting>.self)
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
    sessionController: SessionController,
    mediaChunkRepository: MediaChunkRepository,
    assetLimitSetting: AnySetting<AssetLimitSetting>
  ) {
    self.devicesModel = devicesModel
    self.configureMicrophoneViewBuilder = configureMicrophoneViewBuilder
    self.configureCameraViewBuilder = configureCameraViewBuilder
    self.navigationViewPresenter = navigationViewPresenter
    self.app = app
    self.sessionController = sessionController
    self.appLocaleModel = appLocaleModel
    self.sessionStatusInternal = sessionController.status
    self.mediaChunkRepository = mediaChunkRepository
    self.assetLimitSetting = assetLimitSetting
    setup()
  }

  @Published private(set) var devices = [StartViewModelDevice]()
  var devicesPublished: Published<[StartViewModelDevice]> { _devices }
  var devicesPublisher: Published<[StartViewModelDevice]>.Publisher { $devices }

  @Published private(set) var usedSpace: FileSize?
  var usedSpacePublished: Published<FileSize?> { _usedSpace }
  var usedSpacePublisher: Published<FileSize?>.Publisher { $usedSpace }

  @Published private(set) var spaceLimit: FileSize?
  var spaceLimitPublished: Published<FileSize?> { _spaceLimit }
  var spaceLimitPublisher: Published<FileSize?>.Publisher { $spaceLimit }

  @Published private(set) var lastCapture: Date?
  var lastCapturePublished: Published<Date?> { _lastCapture }
  var lastCapturePublisher: Published<Date?>.Publisher { $lastCapture }

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
    sessionController.errorPublisher.receive(on: DispatchQueue.main).eraseToAnyPublisher()
  }

  @Published private(set) var sessionStatus: SessionStatus? = .notRunning
  var sessionStatusPublished: Published<SessionStatus?> { _sessionStatus }
  var sessionStatusPublisher: Published<SessionStatus?>.Publisher { $sessionStatus }

  private func setup() {
    mediaChunkRepository.lastCapturePublisher
      .receive(on: DispatchQueue.main)
      .assignWeak(to: \.lastCapture, on: self)
      .store(in: &cancellables)
    mediaChunkRepository.totalFileSizePublisher
      .receive(on: DispatchQueue.main)
      .assignWeak(to: \.usedSpace, on: self)
      .store(in: &cancellables)
    assetLimitSetting.publisher
      .map(\.value)
      .assignWeak(to: \.spaceLimit, on: self)
      .store(in: &cancellables)
    received(devices: devicesModel.devices)
    received(status: sessionController.status)
    sessionController.statusPublisher
      .receive(on: DispatchQueue.main)
      .map { [weak self] status in
        self?.received(status: status)
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

  private let assetLimitSetting: AnySetting<AssetLimitSetting>
  private let mediaChunkRepository: MediaChunkRepository
  private var sessionStatusInternal: SessionStatus
  private var cancellables = Set<AnyCancellable>()
  private let devicesModel: DevicesModel
  private let configureMicrophoneViewBuilder: ConfigureMicrophoneViewBuilder
  private let configureCameraViewBuilder: ConfigureCameraViewBuilder
  private let navigationViewPresenter: NavigationViewPresenter
  private let app: UIApplication
  private let sessionController: SessionController
  private let appLocaleModel: AppLocaleModel
}
