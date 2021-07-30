import AutocontainerKit
import SwiftUI

final class PreviewHistoryTableViewModel: AKBuilder, HistoryTableViewModel {
  func didRemove(at index: Int) {
    let historySelectionComputer = resolve(HistorySelectionComputer.self)!
    selectedIndex = historySelectionComputer.computeSelection(
      cells: cells,
      selectedIndex: selectedIndex,
      indexToRemove: index
    )
    cells.remove(at: index)
  }

  func didShare(at index: Int) {
  }

  @Published var cells = Array(1...5).map {
    HistoryCellViewModel(
      id: url($0),
      preview: .cameraPreview,
      date: PreviewHistoryViewModel.captureDate.addingTimeInterval(.from(minutes: Double($0))),
      duration: .from(minutes: 1),
      fileSize: .from(megabytes: 112)
    )
  }
  var cellsPublished: Published<[HistoryCellViewModel]> { _cells }
  var cellsPublisher: Published<[HistoryCellViewModel]>.Publisher { $cells }

  @Published var selectedIndex = 0
  var selectedIndexPublished: Published<Int> { _selectedIndex }
  var selectedIndexPublisher: Published<Int>.Publisher { $selectedIndex }

  @Published var previews: [URL: UIImage] = Dictionary(
    uniqueKeysWithValues: Array(1...5).map { (url($0), preview($0)) }
  )
  var previewsPublished: Published<[URL: UIImage]> { _previews }
  var previewsPublisher: Published<[URL: UIImage]>.Publisher { $previews }
}

private func preview(_ index: Int) -> UIImage {
  let path = Bundle.main.path(forResource: "preview\(index)", ofType: "png")!
  return UIImage(contentsOfFile: path)!
}

private func url(_ index: Int) -> URL {
  URL(fileURLWithPath: "/dev/null/\(index)")
}
