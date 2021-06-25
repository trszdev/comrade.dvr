import CameraKit

struct TempDevicesStore: DevicesStore {
  func store(devices: [Device]) {
  }

  func loadStoredDevices() -> [Device] {
    [
      .camera(device: CameraDevice(
        isEnabled: true,
        id: CKAVCamera.back.value,
        adjustableConfiguration: ConfigureCameraViewModelImpl.sample.adjustableConfiguration,
        configuration: backCamera
      )),
      .camera(device: CameraDevice(
        isEnabled: false,
        id: CKAVCamera.front.value,
        adjustableConfiguration: ConfigureCameraViewModelImpl.sample.adjustableConfiguration,
        configuration: frontCamera
      )),
      .microphone(device: MicrophoneDevice(
        isEnabled: false,
        id: CKAVMicrophone.builtIn.value,
        adjustableConfiguration: ConfigureMicrophoneViewModelImpl.sample.adjustableConfiguration,
        configuration: microphone
      )),
    ]
  }

  private var frontCamera: CKCameraConfiguration {
    CKCameraConfiguration(
      size: CKSize(width: 640, height: 480),
      zoom: 1.0,
      fps: 30,
      fieldOfView: 45,
      orientation: .portrait,
      autoFocus: .contrastDetection,
      stabilizationMode: .auto,
      videoGravity: .resizeAspectFill,
      videoQuality: .medium,
      useH265: true,
      bitrate: CKBitrate(bitsPerSecond: 15_000_000)
    )
  }

  private var backCamera: CKCameraConfiguration {
    CKCameraConfiguration(
      size: CKSize(width: 1920, height: 1080),
      zoom: 1.0,
      fps: 60,
      fieldOfView: 45,
      orientation: .portrait,
      autoFocus: .contrastDetection,
      stabilizationMode: .auto,
      videoGravity: .resizeAspectFill,
      videoQuality: .high,
      useH265: true,
      bitrate: CKBitrate(bitsPerSecond: 15_000_000)
    )
  }

  private var microphone: CKMicrophoneConfiguration {
    CKMicrophoneConfiguration(
      orientation: .portrait,
      location: .unspecified,
      polarPattern: .stereo,
      duckOthers: false,
      useSpeaker: false,
      useBluetoothCompatibilityMode: false,
      audioQuality: .high
    )
  }
}
