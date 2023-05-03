import ComposableArchitecture
import ComposableArchitectureExtensions
import Assets
import Device
import Util
import CameraKit

public struct DeviceCameraState: Equatable {
  public init(
    enabled: Bool = false,
    isFrontCamera: Bool = false,
    configuration: CameraConfiguration? = nil,
    index: CameraConfigurationIndex = .init()
  ) {
    self.enabled = enabled
    self.isFrontCamera = isFrontCamera
    self.configuration = configuration ?? (isFrontCamera ? .defaultFrontCamera : .defaultBackCamera)
    self.index = index
  }

  var fovIndex: CameraConfigurationIndex.FovIndex {
    index.index[configuration.resolution] ?? .init()
  }

  var fpsAndZoom: CameraConfigurationIndex.FpsAndZoom {
    fovIndex.index[configuration.fov] ?? .init()
  }

  @BindableState public var showAlert: Bool = false
  @BindableState public var enabled: Bool = false
  @BindableState public var configuration: CameraConfiguration = .defaultBackCamera
  public var isFrontCamera: Bool = false
  public var index: CameraConfigurationIndex = .init()
  public var errorFields: Set<PartialKeyPath<CameraConfiguration>> = .init()
  public var isLocked: Bool = false

  public var deviceName: L10n {
    isFrontCamera ? .frontCamera : .backCamera
  }

  public var hasErrors: Bool {
    !errorFields.isEmpty
  }
}

public enum DeviceCameraAction: BindableAction {
  case binding(BindingAction<DeviceCameraState>)
  case onConfigurationChange
  case setBitrate(Bitrate)
}

public let deviceCameraReducer = Reducer<DeviceCameraState, DeviceCameraAction, Void> { state, action, _ in
  switch action {
  case .binding(let action):
    switch action.keyPath {
    case \.$configuration.resolution:
      state.configuration.fov = state.fovIndex.fovs.closest(to: state.configuration.fov) ?? .zero
      state.configuration.fps.clamp(state.fpsAndZoom.fps)
      state.configuration.zoom.clamp(state.fpsAndZoom.zoom)
    case \.$configuration.fov:
      state.configuration.fps.clamp(state.fpsAndZoom.fps)
      state.configuration.zoom.clamp(state.fpsAndZoom.zoom)
    case \.showAlert, \.$configuration.zoom, \.$configuration.bitrate:
      return .none
    default:
      break
    }
    return .init(value: .onConfigurationChange)
  case .setBitrate(let bitrate):
    state.configuration.bitrate = bitrate
    return .init(value: .onConfigurationChange)
  default:
    break
  }
  return .none
}
.binding()
