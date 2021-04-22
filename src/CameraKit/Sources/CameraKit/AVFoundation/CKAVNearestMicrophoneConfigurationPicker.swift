struct CKAVNearestMicrophoneConfigurationPicker: CKNearestConfigurationPicker {
  let adjustableConfiguration: CKAdjustableConfiguration

  func nearestConfiguration(for configuration: CKConfiguration) -> CKConfiguration {
    guard let microphone = configuration.microphone,
      let adjustable = adjustableConfiguration.microphone,
      adjustable.id == microphone.id,
      !adjustable.configuration.isEmpty
    else {
      return configuration.with(microphone: nil)
    }
    let nearest = adjustable.configuration.min {
      difference(microphone: microphone.configuration, available: $0) <
        difference(microphone: microphone.configuration, available: $1)
    }!
    let newMicrophone = apply(device: microphone, available: nearest)
    return configuration.with(microphone: newMicrophone)
  }
}

private func apply(
  device: CKDevice<CKMicrophoneConfiguration>,
  available: CKAdjustableMicrophoneConfiguration
) -> CKDevice<CKMicrophoneConfiguration> {
  CKDevice(
    id: device.id,
    configuration: CKMicrophoneConfiguration(
      id: available.id,
      orientation: device.configuration.orientation,
      location: available.location,
      polarPattern: available.polarPattern,
      duckOthers: device.configuration.duckOthers,
      useSpeaker: device.configuration.useSpeaker,
      useBluetoothCompatibilityMode: device.configuration.useBluetoothCompatibilityMode,
      audioQuality: device.configuration.audioQuality
    )
  )
}

private func difference(
  microphone: CKMicrophoneConfiguration,
  available: CKAdjustableMicrophoneConfiguration
) -> Int {
  var difference = 0
  if microphone.location != available.location {
    difference += 1000
  }
  if microphone.polarPattern != available.polarPattern {
    difference += 100
  }
  if difference != 0, available.polarPattern == .unspecified, available.location == .unspecified {
    return 10000
  }
  return difference
}
