import SwiftUI
import Combine
import AVFoundation
import CameraKit

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
    historySelectionViewModel.selectedDayPublisher
      .flatMap { [weak self] (selectedDay: Date?) -> AnyPublisher<[MediaChunk], Never> in
        guard let self = self, let device = historySelectionViewModel.selectedDevice, let day = selectedDay else {
          return Empty<[MediaChunk], Never>().eraseToAnyPublisher()
        }
        return self.repository.mediaChunks(device: device, day: day).eraseToAnyPublisher()
      }
      .compactMap { [weak self] (mediaChunks: [MediaChunk]) in
        self.flatMap { mediaChunks.map($0.cellViewModel(from:)) }
      }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] cells in
        self?.cells = cells
        self?.selectedIndex = 0
      }
      .store(in: &repositoryCancellables)
    historySelectionViewModel.selectedDevicePublisher
      .flatMap { [weak self] (selectedDevice: CKDeviceID?) -> AnyPublisher<[MediaChunk], Never> in
        guard let self = self, let device = selectedDevice, let day = historySelectionViewModel.selectedDay else {
          return Empty<[MediaChunk], Never>().eraseToAnyPublisher()
        }
        return self.repository.mediaChunks(device: device, day: day).eraseToAnyPublisher()
      }
      .compactMap { [weak self] (mediaChunks: [MediaChunk]) in
        self.flatMap { mediaChunks.map($0.cellViewModel(from:)) }
      }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] cells in
        self?.cells = cells
        self?.selectedIndex = 0
      }
      .store(in: &repositoryCancellables)
  }

  @Published private(set) var cells = [HistoryCellViewModel]()
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

  private func loadPreviewImage(for asset: URL) -> Future<(UIImage, URL)?, Never> {
    fatalError()
  }

  private let fileManager: FileManager
  private var historySelectionViewModel: HistorySelectionViewModel
  private let repository: MediaChunkRepository
  private var repositoryCancellables = Set<AnyCancellable>()
  private var thumbnailCancellable: AnyCancellable!
  private let shareViewPresenter: ShareViewPresenter
  private let historySelectionComputer: HistorySelectionComputer
}
