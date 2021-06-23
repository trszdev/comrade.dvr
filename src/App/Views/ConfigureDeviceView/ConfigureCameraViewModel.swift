import SwiftUI
import CameraKit

protocol ConfigureCameraViewModel: ObservableObject {
  var adjustableConfiguration: CKUIAdjustableCameraConfiguration { get }
  var adjustableConfigurationPublished: Published<CKUIAdjustableCameraConfiguration> { get }
  var adjustableConfigurationPublisher: Published<CKUIAdjustableCameraConfiguration>.Publisher { get }

  var isEnabled: Bool { get set }
  var isEnabledPublished: Published<Bool> { get }
  var isEnabledPublisher: Published<Bool>.Publisher { get }

  var resolution: CKSize { get set }
  var resolutionPublished: Published<CKSize> { get }
  var resolutionPublisher: Published<CKSize>.Publisher { get }

  var fps: Int { get set }
  var fpsPublished: Published<Int> { get }
  var fpsPublisher: Published<Int>.Publisher { get }

  var quality: CKQuality { get set }
  var qualityPublished: Published<CKQuality> { get }
  var qualityPublisher: Published<CKQuality>.Publisher { get }

  var useH265: Bool { get set }
  var useH265Published: Published<Bool> { get }
  var useH265Publisher: Published<Bool>.Publisher { get }

  var bitrate: CKBitrate { get set }
  var bitratePublished: Published<CKBitrate> { get }
  var bitratePublisher: Published<CKBitrate>.Publisher { get }

  var zoom: Double { get set }
  var zoomPublished: Published<Double> { get }
  var zoomPublisher: Published<Double>.Publisher { get }

  var fov: Int { get set }
  var fovPublished: Published<Int> { get }
  var fovPublisher: Published<Int>.Publisher { get }

  var autofocus: CKAutoFocus { get set }
  var autofocusPublished: Published<CKAutoFocus> { get }
  var autofocusPublisher: Published<CKAutoFocus>.Publisher { get }
}

final class ConfigureCameraViewModelImpl: ConfigureCameraViewModel {
  init(
    adjustableConfiguration: CKUIAdjustableCameraConfiguration,
    isEnabled: Bool,
    resolution: CKSize,
    fps: Int,
    quality: CKQuality,
    useH265: Bool,
    bitrate: CKBitrate,
    zoom: Double,
    fov: Int,
    autofocus: CKAutoFocus
  ) {
    self.adjustableConfiguration = adjustableConfiguration
    self.isEnabled = isEnabled
    self.resolution = resolution
    self.fps = fps
    self.quality = quality
    self.useH265 = useH265
    self.bitrate = bitrate
    self.zoom = zoom
    self.fov = fov
    self.autofocus = autofocus
  }

  @Published var adjustableConfiguration: CKUIAdjustableCameraConfiguration
  var adjustableConfigurationPublished: Published<CKUIAdjustableCameraConfiguration> {
    _adjustableConfiguration
  }
  var adjustableConfigurationPublisher: Published<CKUIAdjustableCameraConfiguration>.Publisher {
    $adjustableConfiguration
  }

  @Published var isEnabled: Bool
  var isEnabledPublished: Published<Bool> { _isEnabled }
  var isEnabledPublisher: Published<Bool>.Publisher { $isEnabled }

  @Published var resolution: CKSize
  var resolutionPublished: Published<CKSize> { _resolution }
  var resolutionPublisher: Published<CKSize>.Publisher { $resolution }

  @Published var fps: Int
  var fpsPublished: Published<Int> { _fps }
  var fpsPublisher: Published<Int>.Publisher { $fps }

  @Published var quality: CKQuality
  var qualityPublished: Published<CKQuality> { _quality }
  var qualityPublisher: Published<CKQuality>.Publisher { $quality }

  @Published var useH265: Bool
  var useH265Published: Published<Bool> { _useH265 }
  var useH265Publisher: Published<Bool>.Publisher { $useH265 }

  @Published var bitrate: CKBitrate
  var bitratePublished: Published<CKBitrate> { _bitrate }
  var bitratePublisher: Published<CKBitrate>.Publisher { $bitrate }

  @Published var zoom: Double
  var zoomPublished: Published<Double> { _zoom }
  var zoomPublisher: Published<Double>.Publisher { $zoom }

  @Published var fov: Int
  var fovPublished: Published<Int> { _fov }
  var fovPublisher: Published<Int>.Publisher { $fov }

  @Published var autofocus: CKAutoFocus
  var autofocusPublished: Published<CKAutoFocus> { _autofocus }
  var autofocusPublisher: Published<CKAutoFocus>.Publisher { $autofocus }

  static let sample = ConfigureCameraViewModelImpl(
    adjustableConfiguration: sampleAdjustableConfiguration,
    isEnabled: true,
    resolution: CKSize(width: 1920, height: 1080),
    fps: 30,
    quality: .high,
    useH265: true,
    bitrate: CKBitrate(bitsPerSecond: 30_000),
    zoom: 1.0,
    fov: 45,
    autofocus: .contrastDetection
  )

  static let sampleAdjustableConfiguration = CKUIAdjustableCameraConfiguration(
    sizes: [CKSize(width: 1920, height: 1080), CKSize(width: 1280, height: 720)],
    minZoom: 1.0,
    maxZoom: 1.5,
    minFps: 30,
    maxFps: 60,
    minFieldOfView: 30,
    maxFieldOfView: 45,
    supportedStabilizationModes: [.auto, .cinematic],
    isMulticamAvailable: true
  )
}
