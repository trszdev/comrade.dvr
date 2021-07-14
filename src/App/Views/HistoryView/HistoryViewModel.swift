import SwiftUI
import CameraKit
import Combine

protocol HistoryViewModel: ObservableObject, HistorySelectionViewModel {
  func presentSelectDeviceScreen()
  func presentSelectDayScreen()
}

final class HistoryViewModelImpl: HistoryViewModel {
  init(repository: CKMediaChunkRepository) {
    repository.mediaChunkPublisher
      .sink { [weak self] _ in
        self?.selectionCancellable = repository.availableSelections()
          .sink { selections in
            // recompute selections
            self?.availableSelections = selections
          }
      }
      .store(in: &cancellables)
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
  }

  func presentSelectDayScreen() {
    // display dates for selected device
  }

  private var availableSelections = [CKDeviceID: [Date]]()
  private var cancellables = Set<AnyCancellable>()
  private var selectionCancellable: AnyCancellable!
}
