import SwiftUI
import Combine
import CameraKit

protocol SessionViewModel: ObservableObject {
  var previews: [AnyView] { get }
  func stopSession()

  var microphoneEnabled: Bool { get set }
  var microphoneEnabledPublished: Published<Bool> { get }
  var microphoneEnabledPublisher: Published<Bool>.Publisher { get }

  var microphoneMuted: Bool { get set }
  var microphoneMutedPublished: Published<Bool> { get }
  var microphoneMutedPublisher: Published<Bool>.Publisher { get }

  var pressureLevel: CKPressureLevel { get }
  var pressureLevelPublished: Published<CKPressureLevel> { get }
  var pressureLevelPublisher: Published<CKPressureLevel>.Publisher { get }

  var infoText: String { get }
  var infoTextPublished: Published<String> { get }
  var infoTextPublisher: Published<String>.Publisher { get }

  func scheduleDismissAlertTimer()
  var dismissAlertPublisher: AnyPublisher<Void, Never> { get }
}

struct SessionViewModelBuilder {
  let appLocaleModel: AppLocaleModel

  func makeViewModel(session: CKSession? = nil, devices: [Device] = []) -> SessionViewModelImpl {
    SessionViewModelImpl(session: session, appLocaleModel: appLocaleModel, devices: devices)
  }
}

class SessionViewModelImpl: SessionViewModel {
  init(session: CKSession?, appLocaleModel: AppLocaleModel, devices: [Device]) {
    self.session = session
    microphoneEnabled = session == nil || session?.microphone != nil
    microphoneMuted = session?.microphone?.isMuted == true
    infoText = session.flatMap { $0.description(appLocale: appLocaleModel.appLocale) } ?? "test test"
    if let session = session {
      let indeces = Dictionary(uniqueKeysWithValues: devices.enumerated().map { ($0.element.id, $0.offset) })
      let views = session.cameras.sorted { (indeces[$0.key] ?? 0) < (indeces[$1.key] ?? 0) }.map(\.value.previewView)
      previews = views.map { $0.eraseToAnyView() }
    } else {
      previews = [
        Color.green.eraseToAnyView(),
        Color.orange.eraseToAnyView(),
      ]
    }
    pressureLevel = session?.pressureLevel ?? .nominal
    session?.pressureLevelPublisher
      .assignWeak(to: \.pressureLevel, on: self)
      .store(in: &cancellables)
    appLocaleModel.appLocalePublisher
      .compactMap { [weak self] appLocale in
        (self?.session).flatMap { $0.description(appLocale: appLocale) }
      }
      .assignWeak(to: \.infoText, on: self)
      .store(in: &cancellables)
  }

  weak var sessionViewController: SessionViewController?

  let previews: [AnyView]

  func stopSession() {
    sessionViewController?.dismiss(animated: true, completion: nil)
  }

  @Published var microphoneMuted: Bool {
    didSet {
      session?.microphone?.isMuted = microphoneMuted
    }
  }
  var microphoneMutedPublished: Published<Bool> { _microphoneMuted }
  var microphoneMutedPublisher: Published<Bool>.Publisher { $microphoneMuted }

  @Published private(set) var pressureLevel: CKPressureLevel
  var pressureLevelPublished: Published<CKPressureLevel> { _pressureLevel }
  var pressureLevelPublisher: Published<CKPressureLevel>.Publisher { $pressureLevel }

  @Published var microphoneEnabled: Bool
  var microphoneEnabledPublished: Published<Bool> { _microphoneEnabled }
  var microphoneEnabledPublisher: Published<Bool>.Publisher { $microphoneEnabled }

  @Published var infoText: String
  var infoTextPublished: Published<String> { _infoText }
  var infoTextPublisher: Published<String>.Publisher { $infoText }

  func scheduleDismissAlertTimer() {
    dismissTimer?.invalidate()
    dismissTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] timer in
      guard timer.isValid, let self = self else { return }
      self.dismissAlertPublisherInternal.send()
    }
  }

  var dismissAlertPublisher: AnyPublisher<Void, Never> { dismissAlertPublisherInternal.eraseToAnyPublisher() }

  private var dismissAlertPublisherInternal = PassthroughSubject<Void, Never>()
  private var dismissTimer: Timer?
  private var session: CKSession?
  private var cancellables = Set<AnyCancellable>()
}

private extension CKSession {
  func description(appLocale: AppLocale) -> String {
    var devices = cameras.values.map { $0.device.description(appLocale: appLocale) }
    if let microphone = microphone?.device {
      devices.append(microphone.description(appLocale: appLocale))
    }
    return devices.joined(separator: "\n\n")
  }
}

private extension CKDevice where Configuration == CKCameraConfiguration {
  func description(appLocale: AppLocale) -> String {
    let description = [
      "ID": id.value,
      appLocale.sizeString: appLocale.size(configuration.size),
      appLocale.zoomString: appLocale.zoom(configuration.zoom),
      appLocale.fpsString: appLocale.fps(configuration.fps),
      appLocale.fieldOfViewString: appLocale.fieldOfView(configuration.fieldOfView),
      appLocale.autofocusString: appLocale.autofocus(configuration.autoFocus),
      appLocale.qualityString: appLocale.quality(configuration.videoQuality),
      appLocale.bitrateString: appLocale.bitrate(configuration.bitrate),
      appLocale.useH265String: appLocale.yesNo(configuration.useH265),
    ]
    return description.map { [$0.key, $0.value].joined(separator: ": ") }.joined(separator: "\n")
  }
}

private extension CKDevice where Configuration == CKMicrophoneConfiguration {
  func description(appLocale: AppLocale) -> String {
    let description = [
      "ID": id.value,
      appLocale.deviceLocationString: appLocale.deviceLocation(configuration.location),
      appLocale.qualityString: appLocale.quality(configuration.audioQuality),
      appLocale.polarPatternString: appLocale.polarPattern(configuration.polarPattern),
    ]
    return description.map { [$0.key, $0.value].joined(separator: ": ") }.joined(separator: "\n")
  }
}
