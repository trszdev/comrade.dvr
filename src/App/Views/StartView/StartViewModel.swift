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
}

struct StartViewModelBuilder {
  let devicesModel: DevicesModel
  let configureMicrophoneViewBuilder: ConfigureMicrophoneViewBuilder
  let configureCameraViewBuilder: ConfigureCameraViewBuilder
  let rootVm: RootViewModelImpl
  let navigationViewPresenter: NavigationViewPresenter
  let app: UIApplication
  let ckManager: CKManager

  func makeViewModel() -> StartViewModelImpl<RootViewModelImpl> {
    StartViewModelImpl(
      devicesModel: devicesModel,
      configureMicrophoneViewBuilder: configureMicrophoneViewBuilder,
      configureCameraViewBuilder: configureCameraViewBuilder,
      rootVm: rootVm,
      navigationViewPresenter: navigationViewPresenter,
      app: app,
      ckManager: ckManager
    )
  }
}

final class StartViewModelImpl<RootVM: RootViewModel>: StartViewModel {
  init(
    devicesModel: DevicesModel,
    configureMicrophoneViewBuilder: ConfigureMicrophoneViewBuilder,
    configureCameraViewBuilder: ConfigureCameraViewBuilder,
    rootVm: RootVM,
    navigationViewPresenter: NavigationViewPresenter,
    app: UIApplication,
    ckManager: CKManager
  ) {
    self.devices = devicesModel.devices.map { StartViewModelDevice.from(device: $0, appLocale: rootVm.appLocale) }
    self.devicesModel = devicesModel
    self.configureMicrophoneViewBuilder = configureMicrophoneViewBuilder
    self.configureCameraViewBuilder = configureCameraViewBuilder
    self.rootVm = rootVm
    self.navigationViewPresenter = navigationViewPresenter
    self.app = app
    self.ckManager = ckManager
    devicesModel.devicesPublisher
      .sink { [weak self] devices in
        self?.devices = devices.map { StartViewModelDevice.from(device: $0, appLocale: rootVm.appLocale) }
      }
      .store(in: &cancellables)
    rootVm.appLocalePublisher
      .sink { [weak self] appLocale in
        self?.devices = devicesModel.devices.map { StartViewModelDevice.from(device: $0, appLocale: appLocale) }
      }
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
      navigationViewPresenter.presentView(content: { [configureCameraViewBuilder] in
        configureCameraViewBuilder.makeView(viewModel: viewModel)
      })
    case let .microphone(microphoneDevice):
      let viewModel = ConfigureMicrophoneViewModelImpl(devicesModel: devicesModel, microphoneDevice: microphoneDevice)
      navigationViewPresenter.presentView(content: { [configureMicrophoneViewBuilder] in
        configureMicrophoneViewBuilder.makeView(viewModel: viewModel)
      })
    }
  }

  func start() {
    ckManager.sessionMakerPublisher
      .tryMap { [devicesModel] sesionMaker in
        let configuration = devicesModel.devices.configuration
        return try sesionMaker.makeSession(configuration: configuration)
      }
      .mapError { [errorSubject] (error: Error) -> Error in
        errorSubject.send(error)
        return error
      }
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { _ in}, receiveValue: { [navigationViewPresenter] (session: CKSession) in
        navigationViewPresenter.presentView {
          session.cameras.first!.value.previewView
        }
      })
      .store(in: &cancellables)
  }

  func openSettingsUrl() {
    guard let url = URL(string: UIApplication.openSettingsURLString), app.canOpenURL(url) else { return }
    app.open(url, options: [:], completionHandler: nil)
  }

  var errors: AnyPublisher<Error, Never> {
    errorSubject.eraseToAnyPublisher()
  }

  private let errorSubject = PassthroughSubject<Error, Never>()
  private var cancellables = Set<AnyCancellable>()
  private let devicesModel: DevicesModel
  private let configureMicrophoneViewBuilder: ConfigureMicrophoneViewBuilder
  private let configureCameraViewBuilder: ConfigureCameraViewBuilder
  private let rootVm: RootVM
  private let navigationViewPresenter: NavigationViewPresenter
  private let app: UIApplication
  private let ckManager: CKManager
}
