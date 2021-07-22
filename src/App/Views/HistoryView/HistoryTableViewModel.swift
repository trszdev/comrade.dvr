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
  var previews: [URL: UIImage] { get }
  var previewsPublished: Published<[URL: UIImage]> { get }
  var previewsPublisher: Published<[URL: UIImage]>.Publisher { get }
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
      .sink { [weak self] selectedDay in
        self?.scheduleUpdate(selectedDay: selectedDay)
      }
      .store(in: &repositoryCancellables)
    historySelectionViewModel.selectedDevicePublisher
      .sink { [weak self] selectedDevice in
        self?.scheduleUpdate(selectedDevice: selectedDevice)
      }
      .store(in: &repositoryCancellables)
  }

  @Published private(set) var cells = [HistoryCellViewModel]()
  var cellsPublished: Published<[HistoryCellViewModel]> { _cells }
  var cellsPublisher: Published<[HistoryCellViewModel]>.Publisher { $cells }

  @Published var selectedIndex = 0 {
    didSet {
      historySelectionViewModel?.selectedPlayerUrl = cells.isEmpty ? nil : cells[selectedIndex].id
    }
  }
  var selectedIndexPublished: Published<Int> { _selectedIndex }
  var selectedIndexPublisher: Published<Int>.Publisher { $selectedIndex }

  @Published private(set) var previews = [URL: UIImage]()
  var previewsPublished: Published<[URL: UIImage]> { _previews }
  var previewsPublisher: Published<[URL: UIImage]>.Publisher { $previews }

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

  private func scheduleUpdate(selectedDay: Date? = nil, selectedDevice: CKDeviceID? = nil) {
    guard let day = selectedDay ?? historySelectionViewModel?.selectedDay,
      let device = selectedDevice ?? historySelectionViewModel?.selectedDevice
    else {
      return
    }
    updateCancellable = repository.mediaChunks(device: device, day: day)
      .compactMap { [weak self] (mediaChunks: [MediaChunk]) in
        self.flatMap { mediaChunks.map($0.cellViewModel(from:)) }
      }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] cells in
        guard let self = self else { return }
        self.previews = [:]
        self.cells = cells
        self.selectedIndex = 0
        self.previewCancellable = cells.publisher
          .subscribe(on: DispatchQueue.global(qos: .userInitiated))
          .filter { $0.preview == .cameraPreview }
          .map(\.id)
          .flatMap { [weak self] (url: URL) -> AnyPublisher<(URL, UIImage)?, Never> in
            guard let self = self else {
              return Empty().eraseToAnyPublisher()
            }
            return self.loadPreviewImage(for: url).eraseToAnyPublisher()
          }
          .compactMap { (preview: (URL, UIImage)?) -> (URL, UIImage)? in preview }
          .collect()
          .receive(on: DispatchQueue.main)
          .sink { previews in
            self.previews = Dictionary(previews) { $1 }
          }
      }
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

  private func loadPreviewImage(for url: URL) -> Future<(URL, UIImage)?, Never> {
    Future { promise in
      let asset = AVAsset(url: url)
      let imageGenerator = AVAssetImageGenerator(asset: asset)
      let time = CMTime(seconds: asset.duration.seconds / 2, preferredTimescale: asset.duration.timescale)
      let times = [NSValue(time: time)]
      imageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { _, image, _, _, _ in
        if let image = image {
          let result = (url, UIImage(cgImage: image))
          promise(.success(result))
        } else {
          promise(.success(nil))
        }
      })
    }
  }

  private var previewCancellable: AnyCancellable?
  private var updateCancellable: AnyCancellable?
  private let fileManager: FileManager
  private weak var historySelectionViewModel: HistorySelectionViewModel?
  private let repository: MediaChunkRepository
  private var repositoryCancellables = Set<AnyCancellable>()
  private let shareViewPresenter: ShareViewPresenter
  private let historySelectionComputer: HistorySelectionComputer
}
