struct CKAVNearestConfigurationPicker: CKNearestConfigurationPicker {
  let adjustableConfiguration: CKAdjustableConfiguration

  func nearestConfiguration(for configuration: CKConfiguration) -> CKConfiguration {
    let conf = nearestCameraConfiguration(configuration: configuration)
    return adjustableConfiguration.microphone == nil ? conf : conf.with(microphone: nil)
  }

  private func nearestCameraConfiguration(configuration: CKConfiguration) -> CKConfiguration {
    let newCameras = configuration.cameras.filter { adjustableConfiguration.cameras.keys.contains($0.key) }
    let newConfigurations: [CKDeviceID: CKDevice<CKCameraConfiguration>] = newCameras
      .compactMapValues { device in
        let deviceId = device.id
        guard let adjustables = adjustableConfiguration.cameras[deviceId]?.configuration else { return nil }
        let checkMulti = newCameras.count > 1
        let minConf = adjustables.min {
          difference(camera: device.configuration, available: $0, checkMulti: checkMulti) <
            difference(camera: device.configuration, available: $1, checkMulti: checkMulti)
        }
        return minConf.flatMap { apply(device: device, available: $0) }
      }
    return configuration.with(cameras: newConfigurations)
  }

  private func apply(
    device: CKDevice<CKCameraConfiguration>,
    available: CKAdjustableCameraConfiguration
  ) -> CKDevice<CKCameraConfiguration> {
    CKDevice(
      id: device.id,
      configuration: CKCameraConfiguration(
        id: available.id,
        size: available.size,
        zoom: clamp(lower: available.minZoom, value: device.configuration.zoom, upper: available.maxZoom),
        fps: clamp(lower: available.minFps, value: device.configuration.fps, upper: available.maxFps),
        fieldOfView: available.fieldOfView,
        orientation: device.configuration.orientation,
        autoFocus: device.configuration.autoFocus,
        stabilizationMode: available.supportedStabilizationModes.contains(device.configuration.stabilizationMode) ?
          device.configuration.stabilizationMode :
          .auto,
        videoGravity: device.configuration.videoGravity
      )
    )
  }

  private func difference(
    camera: CKCameraConfiguration,
    available: CKAdjustableCameraConfiguration,
    checkMulti: Bool
  ) -> Int {
    var difference = 0
    if camera.size != available.size {
      difference += 1000
    }
    if camera.fieldOfView != available.fieldOfView {
      difference += 100
    }
    if camera.zoom > available.maxZoom || camera.zoom < available.minZoom {
      difference += 100
    }
    if camera.fps > available.maxFps || camera.fps < available.minFps {
      difference += 10
    }
    if !available.supportedStabilizationModes.contains(camera.stabilizationMode) {
      difference += 10
    }
    return difference
  }
}

private func clamp<T: Comparable>(lower: T, value: T, upper: T) -> T {
  min(max(value, lower), upper)
}
