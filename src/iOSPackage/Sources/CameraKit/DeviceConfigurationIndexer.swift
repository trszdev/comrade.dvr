import Device
import AVFoundation
import Util

public protocol DeviceConfigurationIndexer {
  func makeIndex() async -> DeviceConfigurationIndex
  func makeDefaultConfig(index: DeviceConfigurationIndex) -> Device.DeviceConfiguration
}

struct DeviceConfigurationIndexerImpl: DeviceConfigurationIndexer {
  let discovery: Discovery = .init()

  func makeIndex() async -> DeviceConfigurationIndex {
    await withTaskGroup(of: DeviceConfigurationIndex.self) { _ in
      DeviceConfigurationIndex(
        backCamera: makeIndex(devices: discovery.backCameras),
        frontCamera: makeIndex(devices: discovery.frontCameras)
      )
    }
  }

  func makeDefaultConfig(index: DeviceConfigurationIndex) -> Device.DeviceConfiguration {
    var result = Device.DeviceConfiguration()
    if let resolution = index.backCamera.defaultResolution, let fovIndex = index.backCamera.index[resolution] {
      result.backCamera.resolution = resolution
      result.backCamera.fov = fovIndex.fovs.closest(to: 70) ?? 70
      result.backCamera.fps = fovIndex.index[result.backCamera.fov].defaultFps
      result.backCamera.zoom = fovIndex.index[result.backCamera.fov]?.zoom.lowerBound ?? 1
    } else {
      result.backCameraEnabled = false
    }
    if let resolution = index.frontCamera.defaultResolution, let fovIndex = index.frontCamera.index[resolution] {
      result.frontCamera.resolution = resolution
      result.frontCamera.fov = fovIndex.fovs.closest(to: 70) ?? 70
      result.frontCamera.fps = fovIndex.index[result.frontCamera.fov].defaultFps
      result.frontCamera.zoom = fovIndex.index[result.frontCamera.fov]?.zoom.lowerBound ?? 1
      result.frontCameraEnabled = !result.backCameraEnabled
    }
    return result
  }

  private func makeIndex(devices: [AVCaptureDevice]) -> CameraConfigurationIndex {
    var resolutionIndex = CameraConfigurationIndex()

    devices.lazy.flatMap(\.formats).forEach { format in
      let zoom = 1...max(1, Double(format.videoMaxZoomFactor))
      let minFps = format.videoSupportedFrameRateRanges.lazy.map(\.minFrameRate).min()
      let maxFps = format.videoSupportedFrameRateRanges.lazy.map(\.maxFrameRate).max()
      var fps = 1...60
      if let minFps, let maxFps {
        fps = Int(minFps)...Int(max(minFps, maxFps))
      }

      var fovIndex = resolutionIndex.index[format.resolution] ?? .init()
      var fpsAndZoom = fovIndex.index[format.fov] ?? .init(fps: fps, zoom: zoom)
      fpsAndZoom.fps = fps.union(fpsAndZoom.fps)
      fpsAndZoom.zoom = zoom.union(fpsAndZoom.zoom).clamped(to: 1...8)

      fovIndex.index[format.fov] = fpsAndZoom
      resolutionIndex.index[format.resolution] = fovIndex
    }

    resolutionIndex.resolutions = resolutionIndex.index.keys.sorted()
    resolutionIndex.resolutions.forEach { resolution in
      let fovs = resolutionIndex.index[resolution]?.index.keys.sorted() ?? []
      resolutionIndex.index[resolution]?.fovs = fovs
    }
    return resolutionIndex
  }
}

private extension CameraConfigurationIndex {
  var defaultResolution: Resolution? {
    index[.p1080] == nil ? resolutions.last : .p1080
  }
}

private extension CameraConfigurationIndex.FpsAndZoom? {
  var defaultFps: Int {
    (self?.fps).flatMap { $0.contains(60) ? 60 : $0.upperBound } ?? 60
  }
}
