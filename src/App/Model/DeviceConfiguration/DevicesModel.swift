import CameraKit
import Combine

protocol DevicesModel: AnyObject {
  var devicesPublisher: AnyPublisher<[Device], Never> { get }
  func devicePublisher(id: CKDeviceID) -> AnyPublisher<Device, Never>
  var devices: [Device] { get }
  func device(id: CKDeviceID) -> Device?
  func update(device: Device)
}

final class DevicesModelImpl: DevicesModel {
  init(devicesStore: DevicesStore, nearestConfigurationPicker: CKNearestConfigurationPicker) {
    self.devicesStore = devicesStore
    self.nearestConfigurationPicker = nearestConfigurationPicker
    let devices = devicesStore.loadStoredDevices()
    self.devicesSubject = CurrentValueSubject<[Device], Never>(devices)
    self.deviceSubjectMap = Dictionary(devices.enumerated().map { (index, device) in
      (device.id, (index, CurrentValueSubject<Device, Never>(device)))
    }) { $1 }
  }

  var devicesPublisher: AnyPublisher<[Device], Never> { devicesSubject.eraseToAnyPublisher() }

  func devicePublisher(id: CKDeviceID) -> AnyPublisher<Device, Never> {
    guard let (_, subject) = deviceSubjectMap[id] else {
      return PassthroughSubject<Device, Never>().eraseToAnyPublisher()
    }
    return subject.eraseToAnyPublisher()
  }

  var devices: [Device] { devicesSubject.value }

  func device(id: CKDeviceID) -> Device? {
    deviceSubjectMap[id]?.1.value
  }

  func update(device: Device) {
    guard let (index, subject) = deviceSubjectMap[device.id], subject.value != device else { return }
    var devices = self.devices
    devices[index] = device
    let newConfiguration = nearestConfigurationPicker.nearestConfiguration(for: devices.configuration)
    for device in devices {
      guard let (existingIndex, existingSubject) = deviceSubjectMap[device.id] else { continue }
      let newDevice = newConfiguration.device(device: device)
      guard newDevice != existingSubject.value else { continue }
      devices[existingIndex] = newDevice
      existingSubject.send(newDevice)
    }
    devicesStore.store(devices: devices)
    devicesSubject.send(devices)
  }

  private var devicesSubject: CurrentValueSubject<[Device], Never>
  private var deviceSubjectMap: [CKDeviceID: (Int, CurrentValueSubject<Device, Never>)]
  private let devicesStore: DevicesStore
  private let nearestConfigurationPicker: CKNearestConfigurationPicker
}
