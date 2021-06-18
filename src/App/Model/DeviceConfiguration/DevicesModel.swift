import CameraKit
import Combine

protocol DevicesModel {
  var devicesPublisher: AnyPublisher<[Device], Never> { get }
  func devicePublisher(id: CKDeviceID) -> AnyPublisher<Device, Never>
  var devices: [Device] { get }
  func update(device: Device)
}

final class DevicesModelImpl: DevicesModel {
  init(devicesStore: DevicesStore) {
    self.devicesStore = devicesStore
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

  func update(device: Device) {
    let subject: CurrentValueSubject<Device, Never>
    let index: Int
    if let (existingIndex, existingSubject) = deviceSubjectMap[device.id] {
      subject = existingSubject
      index = existingIndex
    } else {
      subject = CurrentValueSubject<Device, Never>(device)
      index = deviceSubjectMap.count
      deviceSubjectMap[device.id] = (index, subject)
    }
    var devices = self.devices
    devices[index] = device
    subject.send(device)
    devicesSubject.send(devices)
    devicesStore.store(device: device)
  }

  private var devicesSubject: CurrentValueSubject<[Device], Never>
  private var deviceSubjectMap: [CKDeviceID: (Int, CurrentValueSubject<Device, Never>)]
  private let devicesStore: DevicesStore
}
