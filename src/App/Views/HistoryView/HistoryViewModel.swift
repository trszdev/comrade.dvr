import SwiftUI
import CameraKit
import Combine

protocol HistoryViewModel: ObservableObject, HistorySelectionViewModel {
  func presentSelectDeviceScreen()
  func presentSelectDayScreen()
}

final class HistoryViewModelImpl: HistoryViewModel {
  init(repository: MediaChunkRepository, navigationViewPresenter: NavigationViewPresenter) {
    self.repository = repository
    self.navigationViewPresenter = navigationViewPresenter
    selectionCancellable = repository.availableSelectionsPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] selections in
        guard let self = self else { return }
        self.availableSelections = selections
        self.recomputeSelection()
      }
  }

  @Published private(set) var selectedDevice: CKDeviceID?
  var selectedDevicePublished: Published<CKDeviceID?> { _selectedDevice }
  var selectedDevicePublisher: Published<CKDeviceID?>.Publisher { $selectedDevice }

  @Published private(set) var selectedDay: Date?
  var selectedDayPublished: Published<Date?> { _selectedDay }
  var selectedDayPublisher: Published<Date?>.Publisher { $selectedDay }

  @Published var selectedPlayerUrl: URL? {
    didSet {
      recomputeSelection()
    }
  }
  var selectedPlayerUrlPublished: Published<URL?> { _selectedPlayerUrl }
  var selectedPlayerUrlPublisher: Published<URL?>.Publisher { $selectedPlayerUrl }

  func presentSelectDeviceScreen() {
    let devices = availableSelections.keys.sorted { $0.value < $1.value }
    navigationViewPresenter.presentView {
      SelectionView(values: devices, localize: { $0.deviceName($1) }, onSelect: { [weak self] device in
        self?.selectedDevice = device
        self?.navigationViewPresenter.popViewController()
      })
    }
  }

  func presentSelectDayScreen() {
    let dates = (selectedDevice.flatMap { availableSelections[$0] } ?? []).sorted().reversed() as [Date]
    navigationViewPresenter.presentView {
      SelectionView(values: dates, localize: { $0.day(date: $1) }, onSelect: { [weak self] date in
        self?.selectedDay = date
        self?.navigationViewPresenter.popViewController()
      })
    }
  }

  private func recomputeSelection() {
    dump(availableSelections)
    guard availableSelections != [:] else {
      select(device: nil, day: nil)
      return
    }
    guard let selectedDay = selectedDay,
      let selectedDevice = selectedDevice,
      availableSelections[selectedDevice]?.contains(selectedDay) == true
    else {
      selectLatestKnownCameraThenOthers()
      return
    }
  }

  private func select(device: CKDeviceID?, day: Date?) {
    if device != selectedDevice {
      selectedDevice = device
    }
    if day != selectedDay {
      selectedDay = day
    }
  }

  private func selectLatestKnownCameraThenOthers() {
    if let backCameraDates = availableSelections[CKAVCamera.back.value] {
      select(device: CKAVCamera.back.value, day: backCameraDates.max())
      return
    }
    if let frontCameraDates = availableSelections[CKAVCamera.front.value] {
      select(device: CKAVCamera.front.value, day: frontCameraDates.max())
      return
    }
    guard let (device, days) = availableSelections.first else { return }
    select(device: device, day: days.max())
  }

  private var availableSelections = [CKDeviceID: Set<Date>]()
  private let navigationViewPresenter: NavigationViewPresenter
  private var selectionCancellable: AnyCancellable?
  private let repository: MediaChunkRepository
}
