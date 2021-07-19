import SwiftUI
import Combine

protocol HistoryTableViewModel: ObservableObject {
  var cells: [HistoryCellViewModel] { get }
  var cellsPublished: Published<[HistoryCellViewModel]> { get }
  var cellsPublisher: Published<[HistoryCellViewModel]>.Publisher { get }
  var selectedIndex: Int { get set }
  var selectedIndexPublished: Published<Int> { get }
  var selectedIndexPublisher: Published<Int>.Publisher { get }
  func didRemove(at index: Int)
  func didShare(at index: Int)
}

final class HistoryTableViewModelImpl: HistoryTableViewModel {
  init(
    historySelectionViewModel: HistorySelectionViewModel,
    repository: MediaChunkRepository,
    shareViewPresenter: ShareViewPresenter,
    historySelectionComputer: HistorySelectionComputer,
    fileManager: FileManager
  ) {
    self.historySelectionViewModel = historySelectionViewModel
    self.repository = repository
    self.shareViewPresenter = shareViewPresenter
    self.historySelectionComputer = historySelectionComputer
    self.fileManager = fileManager
    historySelectionViewModel.selectedDayPublisher.compactMap { $0 }
      .zip(historySelectionViewModel.selectedDevicePublisher.compactMap { $0 })
      .flatMap { (selectedDay, selectedDevice) in
        repository.mediaChunks(device: selectedDevice, day: selectedDay)
      }
      .compactMap { [weak self] mediaChunks in
        self.flatMap { mediaChunks.map($0.cellViewModel(from:)) }
      }
      .receive(on: DispatchQueue.main)
      .assignWeak(to: \.cells, on: self)
      .store(in: &cancellables)
  }

  @Published private(set) var cells = [HistoryCellViewModel]() {
    didSet {
      selectedIndex = 0
    }
  }
  var cellsPublished: Published<[HistoryCellViewModel]> { _cells }
  var cellsPublisher: Published<[HistoryCellViewModel]>.Publisher { $cells }

  @Published var selectedIndex = 0 {
    didSet {
      historySelectionViewModel.selectedPlayerUrl = cells.isEmpty ? nil : cells[selectedIndex].id
    }
  }
  var selectedIndexPublished: Published<Int> { _selectedIndex }
  var selectedIndexPublisher: Published<Int>.Publisher { $selectedIndex }

  func didRemove(at index: Int) {
    let newSelectedIndex = historySelectionComputer.computeSelection(
      cells: cells,
      selectedIndex: selectedIndex,
      indexToRemove: index
    )
    let cell = cells.remove(at: index)
    selectedIndex = newSelectedIndex
    repository.deleteMediaChunks(with: cell.id)
  }

  func didShare(at index: Int) {
    shareViewPresenter.presentFile(url: cells[index].id)
  }

  private func cellViewModel(from mediaChunk: MediaChunk) -> HistoryCellViewModel {
    let started = TimeInterval.from(nanoseconds: Double(mediaChunk.startedAt.nanoseconds))
    let finished = TimeInterval.from(nanoseconds: Double(mediaChunk.finishedAt.nanoseconds))
    let fileSize = fileManager.fileSize(url: mediaChunk.url)
    return HistoryCellViewModel(
      id: mediaChunk.url,
      preview: fileSize == nil ? .notAvailable : (mediaChunk.fileType == .m4a ? .microphonePreview : .cameraPreview),
      date: mediaChunk.day.addingTimeInterval(started),
      duration: finished - started,
      fileSize: fileSize
    )
  }

  private let fileManager: FileManager
  private var historySelectionViewModel: HistorySelectionViewModel
  private let repository: MediaChunkRepository
  private var cancellables = Set<AnyCancellable>()
  private let shareViewPresenter: ShareViewPresenter
  private let historySelectionComputer: HistorySelectionComputer
}
