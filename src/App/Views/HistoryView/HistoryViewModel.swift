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
    repository.mediaChunkPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] mediaChunk in
        print(Date())
        print(mediaChunk)
        self?.requestSelections()
      }
      .store(in: &cancellables)
    self.requestSelections()
  }

  @Published private(set) var selectedDevice: CKDeviceID?
  var selectedDevicePublished: Published<CKDeviceID?> { _selectedDevice }
  var selectedDevicePublisher: Published<CKDeviceID?>.Publisher { $selectedDevice }

  @Published private(set) var selectedDay: Date?
  var selectedDayPublished: Published<Date?> { _selectedDay }
  var selectedDayPublisher: Published<Date?>.Publisher { $selectedDay }

  @Published var selectedPlayerUrl: URL?
  var selectedPlayerUrlPublished: Published<URL?> { _selectedPlayerUrl }
  var selectedPlayerUrlPublisher: Published<URL?>.Publisher { $selectedPlayerUrl }

  func presentSelectDeviceScreen() {
    // display all possible devices
    // on selection modify selected day if needed
    let devices = availableSelections.keys.sorted { $0.value < $1.value }
    navigationViewPresenter.presentView {
      SelectionView(values: devices, localize: { $0.deviceName($1) }, onSelect: { [weak self] device in
        self?.selectedDevice = device
        self?.navigationViewPresenter.popViewController()
      })
    }
  }

  func presentSelectDayScreen() {
    // display dates for selected device
    let dates = (selectedDevice.flatMap { availableSelections[$0] } ?? []).sorted().reversed() as [Date]
    navigationViewPresenter.presentView {
      SelectionView(values: dates, localize: { $0.day(date: $1) }, onSelect: { [weak self] date in
        self?.selectedDay = date
        self?.navigationViewPresenter.popViewController()
      })
    }
  }

  private func requestSelections() {
    selectionCancellable = repository.availableSelections()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] selections in
        self?.availableSelections = selections
        self?.recomputeSelection()
      }
  }

  private func recomputeSelection() {
    guard availableSelections != [:] else {
      deselect()
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

  private func deselect() {
    selectedDevice = nil
    selectedDay = nil
    selectedPlayerUrl = nil
  }

  private func selectLatestKnownCameraThenOthers() {
    if let backCameraDates = availableSelections[CKAVCamera.back.value] {
      selectedDevice = CKAVCamera.back.value
      selectedDay = backCameraDates.max()
      return
    }
    if let frontCameraDates = availableSelections[CKAVCamera.front.value] {
      selectedDevice = CKAVCamera.back.value
      selectedDay = frontCameraDates.max()
      return
    }
    guard let (device, days) = availableSelections.first else { return }
    selectedDevice = device
    selectedDay = days.max()
  }

  private let navigationViewPresenter: NavigationViewPresenter
  private var availableSelections = [CKDeviceID: Set<Date>]()
  private var cancellables = Set<AnyCancellable>()
  private var selectionCancellable: AnyCancellable!
  private let repository: MediaChunkRepository
}
