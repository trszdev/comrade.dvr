import CameraKit

struct TempDevicesStore: DevicesStore {
  func store(device: Device) {
  }

  func loadStoredDevices() -> [Device] {
    [
      Device(isEnabled: true, id: CKAVCamera.back.value, configuration: .camera(configuration: backCamera)),
      Device(isEnabled: false, id: CKAVCamera.front.value, configuration: .camera(configuration: frontCamera)),
      Device(isEnabled: false, id: CKAVMicrophone.builtIn.value, configuration: .microphone(configuration: microphone)),
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
      bitrate: CKBitrate(bitsPerSecond: 30)
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
      bitrate: CKBitrate(bitsPerSecond: 30)
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
