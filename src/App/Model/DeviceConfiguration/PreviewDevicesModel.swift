import CameraKit
import Combine

final class PreviewDevicesModel: DevicesModel {
  var devicesPublisher: AnyPublisher<[Device], Never> {
    CurrentValueSubject<[Device], Never>(devices).eraseToAnyPublisher()
  }

  func devicePublisher(id: CKDeviceID) -> AnyPublisher<Device, Never> {
    if let device = device(id: id) {
      return CurrentValueSubject<Device, Never>(device).eraseToAnyPublisher()
    }
    return PassthroughSubject<Device, Never>().eraseToAnyPublisher()
  }

  var devices: [Device] = [
    .camera(device:
      CameraDevice(
        isEnabled: true,
        id: CKAVCamera.back.value,
        adjustableConfiguration: uiCameraConfiguration,
        configuration: cameraConfiguration
      )
    ),
    .camera(device:
      CameraDevice(
        isEnabled: true,
        id: CKAVCamera.front.value,
        adjustableConfiguration: uiCameraConfiguration,
        configuration: cameraConfiguration
      )
    ),
    .microphone(device:
      MicrophoneDevice(
        isEnabled: false,
        id: CKAVMicrophone.builtIn.value,
        adjustableConfiguration: CKUIAdjustableMicrophoneConfiguration(locations: [], polarPatterns: []),
        configuration: microphoneConfiguration
      )
    ),
  ]

  func device(id: CKDeviceID) -> Device? {
    devices.first { $0.id == id }
  }

  func update(device: Device) {
  }
}

private let microphoneConfiguration = CKMicrophoneConfiguration(
  orientation: .portrait,
  location: .unspecified,
  polarPattern: .unspecified,
  duckOthers: false,
  useSpeaker: false,
  useBluetoothCompatibilityMode: false,
  audioQuality: .high
)

private let uiCameraConfiguration = CKUIAdjustableCameraConfiguration(
  sizes: [],
  minZoom: 0,
  maxZoom: 2,
  minFps: 0,
  maxFps: 30,
  minFieldOfView: 0,
  maxFieldOfView: 200,
  supportedStabilizationModes: [],
  isMulticamAvailable: true
)

private let cameraConfiguration = CKCameraConfiguration(
  size: CKSize(width: 1920, height: 1080),
  zoom: 1.0,
  fps: 30,
  fieldOfView: 107,
  orientation: .portrait,
  autoFocus: .contrastDetection,
  stabilizationMode: .auto,
  videoGravity: .resizeAspectFill,
  videoQuality: .high,
  useH265: true,
  bitrate: CKBitrate(bitsPerSecond: 10_000_000)
)
