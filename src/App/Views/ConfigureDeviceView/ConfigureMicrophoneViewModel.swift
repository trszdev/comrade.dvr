import SwiftUI
import CameraKit
import Combine

protocol ConfigureMicrophoneViewModel: ObservableObject {
  var adjustableConfiguration: CKUIAdjustableMicrophoneConfiguration { get }
  var adjustableConfigurationPublished: Published<CKUIAdjustableMicrophoneConfiguration> { get }
  var adjustableConfigurationPublisher: Published<CKUIAdjustableMicrophoneConfiguration>.Publisher { get }

  var isEnabled: Bool { get set }
  var isEnabledPublished: Published<Bool> { get }
  var isEnabledPublisher: Published<Bool>.Publisher { get }

  var location: CKDeviceLocation { get set }
  var locationPublished: Published<CKDeviceLocation> { get }
  var locationPublisher: Published<CKDeviceLocation>.Publisher { get }

  var polarPattern: CKPolarPattern { get set }
  var polarPatternPublished: Published<CKPolarPattern> { get }
  var polarPatternPublisher: Published<CKPolarPattern>.Publisher { get }

  var quality: CKQuality { get set }
  var qualityPublished: Published<CKQuality> { get }
  var qualityPublisher: Published<CKQuality>.Publisher { get }
}

final class ConfigureMicrophoneViewModelImpl: ConfigureMicrophoneViewModel {
  init(
    adjustableConfiguration: CKUIAdjustableMicrophoneConfiguration,
    isEnabled: Bool,
    location: CKDeviceLocation,
    polarPattern: CKPolarPattern,
    quality: CKQuality
  ) {
    self.adjustableConfiguration = adjustableConfiguration
    self.isEnabled = isEnabled
    self.location = location
    self.polarPattern = polarPattern
    self.quality = quality
  }

  init(devicesModel: DevicesModel, microphoneDevice: MicrophoneDevice) {
    self.devicesModel = devicesModel
    self.microphoneDevice = microphoneDevice
    self.adjustableConfiguration = microphoneDevice.adjustableConfiguration
    self.isEnabled = microphoneDevice.isEnabled
    self.location = microphoneDevice.configuration.location
    self.polarPattern = microphoneDevice.configuration.polarPattern
    self.quality = microphoneDevice.configuration.audioQuality
    cancellable = devicesModel.devicePublisher(id: microphoneDevice.id).sink { [weak self] device in
      guard let self = self, case let .microphone(microphoneDevice) = device else { return }
      let devicesModel = self.devicesModel
      self.devicesModel = nil
      self.microphoneDevice = microphoneDevice
      self.adjustableConfiguration = microphoneDevice.adjustableConfiguration
      self.isEnabled = microphoneDevice.isEnabled
      self.location = microphoneDevice.configuration.location
      self.polarPattern = microphoneDevice.configuration.polarPattern
      self.quality = microphoneDevice.configuration.audioQuality
      self.devicesModel = devicesModel
    }
  }

  @Published var adjustableConfiguration: CKUIAdjustableMicrophoneConfiguration
  var adjustableConfigurationPublished: Published<CKUIAdjustableMicrophoneConfiguration> {
    _adjustableConfiguration
  }

  var adjustableConfigurationPublisher: Published<CKUIAdjustableMicrophoneConfiguration>.Publisher {
    $adjustableConfiguration
  }

  @Published var isEnabled: Bool {
    didSet {
      trySendUpdate(isEnabled: isEnabled)
    }
  }
  var isEnabledPublished: Published<Bool> { _isEnabled }
  var isEnabledPublisher: Published<Bool>.Publisher { $isEnabled }

  @Published var location: CKDeviceLocation {
    didSet {
      trySendUpdate(location: location)
    }
  }
  var locationPublished: Published<CKDeviceLocation> { _location }
  var locationPublisher: Published<CKDeviceLocation>.Publisher { $location }

  @Published var polarPattern: CKPolarPattern {
    didSet {
      trySendUpdate(polarPattern: polarPattern)
    }
  }
  var polarPatternPublished: Published<CKPolarPattern> { _polarPattern }
  var polarPatternPublisher: Published<CKPolarPattern>.Publisher { $polarPattern }

  @Published var quality: CKQuality {
    didSet {
      trySendUpdate(quality: quality)
    }
  }
  var qualityPublished: Published<CKQuality> { _quality }
  var qualityPublisher: Published<CKQuality>.Publisher { $quality }

  static let sample = ConfigureMicrophoneViewModelImpl(
    adjustableConfiguration: sampleConfig,
    isEnabled: true,
    location: .unspecified,
    polarPattern: .stereo,
    quality: .max
  )

  private static let sampleConfig = CKUIAdjustableMicrophoneConfiguration(
    locations: [.unspecified, .top, .bottom],
    polarPatterns: [.unspecified, .stereo, .cardioid]
  )

  private func trySendUpdate(
    isEnabled: Bool? = nil,
    location: CKDeviceLocation? = nil,
    polarPattern: CKPolarPattern? = nil,
    quality: CKQuality? = nil
  ) {
    guard let devicesModel = devicesModel, var microphoneDevice = self.microphoneDevice else { return }
    microphoneDevice.isEnabled = isEnabled ?? self.isEnabled
    var config = microphoneDevice.configuration
    config.location = location ?? self.location
    config.polarPattern = polarPattern ?? self.polarPattern
    config.audioQuality = quality ?? self.quality
    microphoneDevice.configuration = config
    devicesModel.update(device: .microphone(device: microphoneDevice))
  }

  private var cancellable: AnyCancellable!
  private var microphoneDevice: MicrophoneDevice!
  private weak var devicesModel: DevicesModel?
}
