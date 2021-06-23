import SwiftUI
import CameraKit

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

  @Published var adjustableConfiguration: CKUIAdjustableMicrophoneConfiguration
  var adjustableConfigurationPublished: Published<CKUIAdjustableMicrophoneConfiguration> {
    _adjustableConfiguration
  }

  var adjustableConfigurationPublisher: Published<CKUIAdjustableMicrophoneConfiguration>.Publisher {
    $adjustableConfiguration
  }

  @Published var isEnabled: Bool
  var isEnabledPublished: Published<Bool> { _isEnabled }
  var isEnabledPublisher: Published<Bool>.Publisher { $isEnabled }

  @Published var location: CKDeviceLocation
  var locationPublished: Published<CKDeviceLocation> { _location }
  var locationPublisher: Published<CKDeviceLocation>.Publisher { $location }

  @Published var polarPattern: CKPolarPattern
  var polarPatternPublished: Published<CKPolarPattern> { _polarPattern }
  var polarPatternPublisher: Published<CKPolarPattern>.Publisher { $polarPattern }

  @Published var quality: CKQuality
  var qualityPublished: Published<CKQuality> { _quality }
  var qualityPublisher: Published<CKQuality>.Publisher { $quality }

  static let sample = ConfigureMicrophoneViewModelImpl(
    adjustableConfiguration: sampleConfig,
    isEnabled: true,
    location: .unspecified,
    polarPattern: .stereo,
    quality: .max
  )

  static let sampleConfig = CKUIAdjustableMicrophoneConfiguration(
    locations: [.unspecified, .top, .bottom],
    polarPatterns: [.unspecified, .stereo, .cardioid]
  )
}
