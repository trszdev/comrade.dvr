import SwiftUI

protocol StartViewModel: ObservableObject {
  var devices: [StartViewModelDevice] { get }
  var devicesPublished: Published<[StartViewModelDevice]> { get }
  var devicesPublisher: Published<[StartViewModelDevice]>.Publisher { get }

  var canAddNewDevice: Bool { get }
  var canAddNewDevicePublished: Published<Bool> { get }
  var canAddNewDevicePublisher: Published<Bool>.Publisher { get }

  func presentAddNewDeviceScreen()
  func presentConfigureDeviceScreen(for device: StartViewModelDevice)
}

#if DEBUG

final class PreviewStartViewModel: StartViewModel {
  init(
    devices: [Bool] = [true, false, false],
    canAddNewDevice: Bool = true,
    presentAddNewDeviceScreenStub: @escaping () -> Void = {},
    presentConfigureDeviceScreenStub: @escaping (_ device: StartViewModelDevice) -> Void = { _ in }
  ) {
    self.devices = devices.map { isMicrophone in
      StartViewModelDevice(
        name: isMicrophone ? "Microphone" : "Camera",
        details: isMicrophone ? ["Stereo", "High quality"] : ["HD", "60fps", "30kbit/s"]
      )
    }
    self.canAddNewDevice = canAddNewDevice
    self.presentAddNewDeviceScreenStub = presentAddNewDeviceScreenStub
    self.presentConfigureDeviceScreenStub = presentConfigureDeviceScreenStub
  }

  @Published private(set) var devices: [StartViewModelDevice]
  var devicesPublished: Published<[StartViewModelDevice]> { _devices }
  var devicesPublisher: Published<[StartViewModelDevice]>.Publisher { $devices }
  @Published private(set) var canAddNewDevice: Bool
  var canAddNewDevicePublished: Published<Bool> { _canAddNewDevice }
  var canAddNewDevicePublisher: Published<Bool>.Publisher { $canAddNewDevice }

  func presentConfigureDeviceScreen(for device: StartViewModelDevice) {
    presentConfigureDeviceScreenStub(device)
  }

  func presentAddNewDeviceScreen() {
    presentAddNewDeviceScreenStub()
  }

  private let presentAddNewDeviceScreenStub: () -> Void
  private let presentConfigureDeviceScreenStub: (_ device: StartViewModelDevice) -> Void
}

#endif
