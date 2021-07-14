import Foundation
import CameraKit

struct StartViewModelDevice: Identifiable {
  var id = CKDeviceID()
  let name: String
  let details: [String]
  let sfSymbol: SFSymbol
  let isActive: Bool

  static func from(device: Device, appLocale: AppLocale) -> StartViewModelDevice {
    switch device {
    case let .camera(cameraDevice):
      return from(cameraDevice: cameraDevice, appLocale: appLocale)
    case let .microphone(microphoneDevice):
      return from(microphoneDevice: microphoneDevice, appLocale: appLocale)
    }
  }

  static func from(cameraDevice: CameraDevice, appLocale: AppLocale) -> StartViewModelDevice {
    StartViewModelDevice(
      id: cameraDevice.id,
      name: appLocale.deviceName(cameraDevice.id),
      details: [
        appLocale.size(cameraDevice.configuration.size),
        appLocale.fps(cameraDevice.configuration.fps),
        appLocale.qualityLong(cameraDevice.configuration.videoQuality),
      ],
      sfSymbol: .camera,
      isActive: cameraDevice.isEnabled
    )
  }

  static func from(microphoneDevice: MicrophoneDevice, appLocale: AppLocale) -> StartViewModelDevice {
    StartViewModelDevice(
      id: microphoneDevice.id,
      name: appLocale.deviceName(microphoneDevice.id),
      details: [
        appLocale.polarPattern(microphoneDevice.configuration.polarPattern),
        appLocale.qualityLong(microphoneDevice.configuration.audioQuality),
      ],
      sfSymbol: .mic,
      isActive: microphoneDevice.isEnabled
    )
  }
}
