import SwiftUI

protocol StartViewModel: ObservableObject {
  var devices: [StartViewModelDevice] { get }
  var devicesPublished: Published<[StartViewModelDevice]> { get }
  var devicesPublisher: Published<[StartViewModelDevice]>.Publisher { get }

  var canAddMicrophone: Bool { get }
  var canAddMicrophonePublished: Published<Bool> { get }
  var canAddMicrophonePublisher: Published<Bool>.Publisher { get }

  var canAddCamera: Bool { get }
  var canAddCameraPublished: Published<Bool> { get }
  var canAddCameraPublisher: Published<Bool>.Publisher { get }

  func presentAddMicrophoneScreen()
  func presentAddCameraScreen()
  func presentConfigureDeviceScreen(for device: StartViewModelDevice)
}

final class StartViewModelImpl: StartViewModel {
  init(
    devices: [Bool] = [true, false, false],
    canAddMicrophone: Bool = true,
    canAddCamera: Bool = true,
    presentAddNewDeviceScreenStub: @escaping () -> Void = {},
    presentConfigureDeviceScreenStub: @escaping (_ device: StartViewModelDevice) -> Void = { _ in }
  ) {
    self.devices = devices.map { isMicrophone in
      StartViewModelDevice(
        name: isMicrophone ? "Microphone" : "Camera",
        details: isMicrophone ? ["Stereo", "High quality"] : ["HD", "60fps", "30kbit/s"],
        sfSymbol: isMicrophone ? .mic : .camera,
        isActive: Bool.random()
      )
    }
    self.canAddMicrophone = canAddMicrophone
    self.canAddCamera = canAddCamera
    self.presentAddNewDeviceScreenStub = presentAddNewDeviceScreenStub
    self.presentConfigureDeviceScreenStub = presentConfigureDeviceScreenStub
  }

  @Published private(set) var devices: [StartViewModelDevice]
  var devicesPublished: Published<[StartViewModelDevice]> { _devices }
  var devicesPublisher: Published<[StartViewModelDevice]>.Publisher { $devices }
  @Published private(set) var canAddMicrophone: Bool
  var canAddMicrophonePublished: Published<Bool> { _canAddMicrophone }
  var canAddMicrophonePublisher: Published<Bool>.Publisher { $canAddMicrophone }
  @Published private(set) var canAddCamera: Bool
  var canAddCameraPublished: Published<Bool> { _canAddCamera }
  var canAddCameraPublisher: Published<Bool>.Publisher { $canAddCamera }

  func presentConfigureDeviceScreen(for device: StartViewModelDevice) {
    presentConfigureDeviceScreenStub(device)
  }

  func presentAddMicrophoneScreen() {
    presentAddNewDeviceScreenStub()
  }

  func presentAddCameraScreen() {
    presentAddNewDeviceScreenStub()
  }

  private let presentAddNewDeviceScreenStub: () -> Void
  private let presentConfigureDeviceScreenStub: (_ device: StartViewModelDevice) -> Void
}
