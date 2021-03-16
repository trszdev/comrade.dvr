public struct CKNearestConfigurationPicker {
  public let adjustableConfiguration: CKAdjustableConfiguration

  public init(adjustableConfiguration: CKAdjustableConfiguration) {
    self.adjustableConfiguration = adjustableConfiguration
  }

  public func nearestConfiguration(for configuration: CKConfiguration) -> CKConfiguration {
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
        id: device.configuration.id,
        size: available.size,
        zoom: device.configuration.zoom.clamp(lower: available.minZoom, upper: available.maxZoom),
        fps: device.configuration.fps.clamp(lower: available.minFps, upper: available.maxFps),
        fieldOfView: available.fieldOfView,
        orientation: device.configuration.orientation,
        autoFocus: device.configuration.autoFocus,
        isVideoMirrored: available.isVideoMirroringAvailable ? device.configuration.isVideoMirrored: false,
        stabilizationMode: available.supportedStabilizationModes.contains(device.configuration.stabilizationMode) ?
          device.configuration.stabilizationMode :
          .auto
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
    if camera.isVideoMirrored, !available.isVideoMirroringAvailable {
      difference += 10
    }
    if !available.supportedStabilizationModes.contains(camera.stabilizationMode) {
      difference += 10
    }
    return difference
  }
}

private extension Comparable {
  func clamp<T: Comparable>(lower: T, upper: T) -> T where Self == T {
    min(max(self, lower), upper)
  }
}
