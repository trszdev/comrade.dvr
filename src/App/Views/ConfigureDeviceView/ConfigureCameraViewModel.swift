import SwiftUI
import CameraKit
import Combine

protocol ConfigureCameraViewModel: ObservableObject {
  var adjustableConfiguration: CKUIAdjustableCameraConfiguration { get }
  var adjustableConfigurationPublished: Published<CKUIAdjustableCameraConfiguration> { get }
  var adjustableConfigurationPublisher: Published<CKUIAdjustableCameraConfiguration>.Publisher { get }

  var isEnabled: Bool { get set }
  var isEnabledBinding: Binding<Bool> { get }
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

extension ConfigureCameraViewModel {
  var isEnabledBinding: Binding<Bool> {
    Binding(get: { self.isEnabled }, set: { self.isEnabled = $0 })
  }
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

  init(devicesModel: DevicesModel, cameraDevice: CameraDevice) {
    self.devicesModel = devicesModel
    self.cameraDevice = cameraDevice
    self.adjustableConfiguration = cameraDevice.adjustableConfiguration
    self.isEnabled = cameraDevice.isEnabled
    self.resolution = cameraDevice.configuration.size
    self.fps = cameraDevice.configuration.fps
    self.quality = cameraDevice.configuration.videoQuality
    self.useH265 = cameraDevice.configuration.useH265
    self.bitrate = cameraDevice.configuration.bitrate
    self.zoom = cameraDevice.configuration.zoom
    self.fov = cameraDevice.configuration.fieldOfView
    self.autofocus = cameraDevice.configuration.autoFocus
    cancellable = devicesModel.devicePublisher(id: cameraDevice.id).sink { [weak self] device in
      guard let self = self, case let .camera(cameraDevice) = device else { return }
      let devicesModel = self.devicesModel
      self.devicesModel = nil
      self.cameraDevice = cameraDevice
      self.adjustableConfiguration = cameraDevice.adjustableConfiguration
      self.isEnabled = cameraDevice.isEnabled
      self.resolution = cameraDevice.configuration.size
      self.fps = cameraDevice.configuration.fps
      self.quality = cameraDevice.configuration.videoQuality
      self.useH265 = cameraDevice.configuration.useH265
      self.bitrate = cameraDevice.configuration.bitrate
      self.zoom = cameraDevice.configuration.zoom
      self.fov = cameraDevice.configuration.fieldOfView
      self.autofocus = cameraDevice.configuration.autoFocus
      self.devicesModel = devicesModel
    }
  }

  @Published var adjustableConfiguration: CKUIAdjustableCameraConfiguration
  var adjustableConfigurationPublished: Published<CKUIAdjustableCameraConfiguration> {
    _adjustableConfiguration
  }
  var adjustableConfigurationPublisher: Published<CKUIAdjustableCameraConfiguration>.Publisher {
    $adjustableConfiguration
  }

  @Published var isEnabled: Bool {
    didSet {
      trySendUpdate(isEnabled: isEnabled)
    }
  }
  var isEnabledPublished: Published<Bool> { _isEnabled }
  var isEnabledPublisher: Published<Bool>.Publisher { $isEnabled }

  @Published var resolution: CKSize {
    didSet {
      trySendUpdate(resolution: resolution)
    }
  }
  var resolutionPublished: Published<CKSize> { _resolution }
  var resolutionPublisher: Published<CKSize>.Publisher { $resolution }

  @Published var fps: Int {
    didSet {
      trySendUpdate(fps: fps)
    }
  }
  var fpsPublished: Published<Int> { _fps }
  var fpsPublisher: Published<Int>.Publisher { $fps }

  @Published var quality: CKQuality {
    didSet {
      trySendUpdate(quality: quality)
    }
  }
  var qualityPublished: Published<CKQuality> { _quality }
  var qualityPublisher: Published<CKQuality>.Publisher { $quality }

  @Published var useH265: Bool {
    didSet {
      trySendUpdate(useH265: useH265)
    }
  }
  var useH265Published: Published<Bool> { _useH265 }
  var useH265Publisher: Published<Bool>.Publisher { $useH265 }

  @Published var bitrate: CKBitrate {
    didSet {
      trySendUpdate(bitrate: bitrate)
    }
  }
  var bitratePublished: Published<CKBitrate> { _bitrate }
  var bitratePublisher: Published<CKBitrate>.Publisher { $bitrate }

  @Published var zoom: Double {
    didSet {
      trySendUpdate(zoom: zoom)
    }
  }
  var zoomPublished: Published<Double> { _zoom }
  var zoomPublisher: Published<Double>.Publisher { $zoom }

  @Published var fov: Int {
    didSet {
      trySendUpdate(fov: fov)
    }
  }
  var fovPublished: Published<Int> { _fov }
  var fovPublisher: Published<Int>.Publisher { $fov }

  @Published var autofocus: CKAutoFocus {
    didSet {
      trySendUpdate(autofocus: autofocus)
    }
  }
  var autofocusPublished: Published<CKAutoFocus> { _autofocus }
  var autofocusPublisher: Published<CKAutoFocus>.Publisher { $autofocus }

  static let sample = ConfigureCameraViewModelImpl(
    adjustableConfiguration: sampleAdjustableConfiguration,
    isEnabled: true,
    resolution: CKSize(width: 1920, height: 1080),
    fps: 30,
    quality: .high,
    useH265: true,
    bitrate: CKBitrate(bitsPerSecond: 15_000_000),
    zoom: 1.0,
    fov: 45,
    autofocus: .contrastDetection
  )

  private static let sampleAdjustableConfiguration = CKUIAdjustableCameraConfiguration(
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

  private func trySendUpdate(
    isEnabled: Bool? = nil,
    resolution: CKSize? = nil,
    fps: Int? = nil,
    quality: CKQuality? = nil,
    useH265: Bool? = nil,
    bitrate: CKBitrate? = nil,
    zoom: Double? = nil,
    fov: Int? = nil,
    autofocus: CKAutoFocus? = nil
  ) {
    guard let devicesModel = devicesModel, var cameraDevice = self.cameraDevice else { return }
    cameraDevice.isEnabled = isEnabled ?? self.isEnabled
    var config = cameraDevice.configuration
    config.size = resolution ?? self.resolution
    config.fps = fps ?? self.fps
    config.videoQuality = quality ?? self.quality
    config.useH265 = useH265 ?? self.useH265
    config.bitrate = bitrate ?? self.bitrate
    config.zoom = zoom ?? self.zoom
    config.fieldOfView = fov ?? self.fov
    config.autoFocus = autofocus ?? self.autofocus
    cameraDevice.configuration = config
    self.cameraDevice = cameraDevice
    devicesModel.update(device: .camera(device: cameraDevice))
  }

  private var cancellable: AnyCancellable!
  private var cameraDevice: CameraDevice!
  private weak var devicesModel: DevicesModel?
}
