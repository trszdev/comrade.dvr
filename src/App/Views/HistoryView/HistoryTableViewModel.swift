import SwiftUI
import Combine

protocol HistoryTableViewModel: ObservableObject {
  var cells: [HistoryCellViewModel] { get }
  var cellsPublished: Published<[HistoryCellViewModel]> { get }
  var cellsPublisher: Published<[HistoryCellViewModel]>.Publisher { get }
  func didRemove(cell: HistoryCellViewModel)
  func didShare(cell: HistoryCellViewModel)
}

final class HistoryTableViewModelImpl: HistoryTableViewModel {
  init(historySelectionViewModel: HistorySelectionViewModel, repository: CKMediaChunkRepository) {
    self.repository = repository
    historySelectionViewModel.selectedDayPublisher.compactMap { $0 }
      .zip(historySelectionViewModel.selectedDevicePublisher.compactMap { $0 })
      .flatMap { (selectedDay, selectedDevice) in
        repository.mediaChunks(device: selectedDevice, day: selectedDay)
      }
      .map { _ in
        // feed media chunks to table view
      }
      .sink {}
      .store(in: &cancellables)
  }

  @Published private(set) var cells = [HistoryCellViewModel]()
  var cellsPublished: Published<[HistoryCellViewModel]> { _cells }
  var cellsPublisher: Published<[HistoryCellViewModel]>.Publisher { $cells }

  func didRemove(cell: HistoryCellViewModel) {
    repository.deleteMediaChunks(with: cell.id)
  }

  func didShare(cell: HistoryCellViewModel) {

  }

  private let repository: CKMediaChunkRepository
  private var cancellables = Set<AnyCancellable>()
}
