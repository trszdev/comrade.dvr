import SwiftUI

protocol HistoryTableViewModel: ObservableObject {
  var cells: [HistoryCellViewModel] { get }
  var cellsPublished: Published<[HistoryCellViewModel]> { get }
  var cellsPublisher: Published<[HistoryCellViewModel]>.Publisher { get }

  func didTap(cell: HistoryCellViewModel)
  func didRemove(cell: HistoryCellViewModel)
  func didShareVideoOnly(cell: HistoryCellViewModel)
  func didExport(cell: HistoryCellViewModel)
}
