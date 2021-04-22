import AVFoundation

struct CKAVNearestSingleCameraConfigurationPicker: CKNearestConfigurationPicker {
  let adjustableConfiguration: CKAdjustableConfiguration

  func nearestConfiguration(for configuration: CKConfiguration) -> CKConfiguration {
    let newCameras = configuration.cameras.filter { adjustableConfiguration.cameras.keys.contains($0.key) }
    let newConfigurations: [CKDeviceID: CKDevice<CKCameraConfiguration>] = newCameras
      .compactMapValues { device in
        guard let adjustables = adjustableConfiguration.cameras[device.id]?.configuration else { return nil }
        let merged = adjustables.map { MergedConfiguration(requested: device.configuration, adjustable: $0) }
        return merged.min()?.apply(deviceId: device.id)
      }
    return configuration.with(cameras: newConfigurations)
  }
}

struct CKAVNearestMultiCameraConfigurationPicker: CKNearestConfigurationPicker {
  struct Builder {
    let multicamSetsProvider: CKAVMulticamSetsProvider

    func makePicker(adjustableConfiguration: CKAdjustableConfiguration) -> CKNearestConfigurationPicker {
      CKAVNearestMultiCameraConfigurationPicker(
        adjustableConfiguration: adjustableConfiguration,
        multicamSetsProvider: multicamSetsProvider
      )
    }
  }

  let adjustableConfiguration: CKAdjustableConfiguration
  let multicamSetsProvider: CKAVMulticamSetsProvider

  func nearestConfiguration(for configuration: CKConfiguration) -> CKConfiguration {
    let multicamSets = multicamSetsProvider.multicamSets
    let mergedSets = multicamSets.compactMap { MergedSet.from(multicamSet: $0, configuration: configuration) }
    guard let minSet = mergedSets.min() else { return configuration.with(cameras: [:]) }
    let newCameras: [(CKDeviceID, CKDevice<CKCameraConfiguration>)] = minSet.value.map { deviceId, mergedConf in
      (deviceId, mergedConf.apply(deviceId: deviceId))
    }
    return configuration.with(cameras: Dictionary(uniqueKeysWithValues: newCameras))
  }
}

private struct MergedConfiguration: Comparable {
  let requested: CKCameraConfiguration
  let adjustable: CKAdjustableCameraConfiguration

  static func < (lhs: MergedConfiguration, rhs: MergedConfiguration) -> Bool {
    return lhs.difference < rhs.difference
  }

  var difference: Int {
    var result = 0
    if requested.size != adjustable.size {
      let requestedScalar = requested.size.width * requested.size.height
      let adjustableScalar = adjustable.size.width * adjustable.size.height
      result += abs(requestedScalar - adjustableScalar)
    }
    if requested.fieldOfView != adjustable.fieldOfView {
      result += 100
    }
    if requested.zoom > adjustable.maxZoom || requested.zoom < adjustable.minZoom {
      result += 100
    }
    if requested.fps > adjustable.maxFps || requested.fps < adjustable.minFps {
      result += 10
    }
    if !adjustable.supportedStabilizationModes.contains(requested.stabilizationMode) {
      result += 10
    }
    return result
  }

  func apply(deviceId: CKDeviceID) -> CKDevice<CKCameraConfiguration> {
    CKDevice(
      id: deviceId,
      configuration: CKCameraConfiguration(
        id: adjustable.id,
        size: adjustable.size,
        zoom: clamp(lower: adjustable.minZoom, value: requested.zoom, upper: adjustable.maxZoom),
        fps: clamp(lower: adjustable.minFps, value: requested.fps, upper: adjustable.maxFps),
        fieldOfView: adjustable.fieldOfView,
        orientation: requested.orientation,
        autoFocus: requested.autoFocus,
        stabilizationMode: adjustable.supportedStabilizationModes.contains(requested.stabilizationMode) ?
          requested.stabilizationMode :
          .auto,
        videoGravity: requested.videoGravity,
        videoQuality: requested.videoQuality,
        useH265: requested.useH265,
        bitrate: requested.bitrate
      )
    )
  }
}

private struct MergedSet: Comparable {
  let value: [CKDeviceID: MergedConfiguration]

  static func < (lhs: MergedSet, rhs: MergedSet) -> Bool {
    guard lhs.value.count == rhs.value.count else {
      return lhs.value.count > rhs.value.count
    }
    let leftSum = lhs.value.reduce(into: 0) { acc, x in acc += x.value.difference }
    let rightSum = rhs.value.reduce(into: 0) { acc, x in acc += x.value.difference }
    return leftSum < rightSum
  }

  static func from(
    multicamSet: Set<CKDevice<[CKAdjustableCameraConfiguration]>>,
    configuration: CKConfiguration
  ) -> MergedSet? {
    var result = [CKDeviceID: MergedConfiguration]()
    for camera in multicamSet {
      guard let requested = configuration.cameras[camera.id]?.configuration else { return nil }
      let mergedConfs = camera.configuration.map { MergedConfiguration(requested: requested, adjustable: $0) }
      guard let mergedConf = mergedConfs.min() else { continue }
      result[camera.id] = mergedConf
    }
    return MergedSet(value: result)
  }
}
