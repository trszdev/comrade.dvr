import SwiftUI
import AutocontainerKit

protocol HistoryTableViewBuilder {
  func makeView() -> AnyView
}

final class HistoryTableViewBuilderImpl: AKBuilder, HistoryTableViewBuilder {
  func makeView() -> AnyView {
    HistoryTableView(
      viewModel: resolve(HistoryTableViewModelImpl.self),
      selectionComputer: resolve(HistorySelectionComputer.self)
    )
    .eraseToAnyView()
  }
}

final class PreviewHistoryTableViewBuilder: AKBuilder, HistoryTableViewBuilder {
  func makeView() -> AnyView {
    HistoryTableView(
      viewModel: resolve(PreviewHistoryTableViewModel.self),
      selectionComputer: resolve(HistorySelectionComputer.self)
    )
    .eraseToAnyView()
  }
}

struct HistoryTableView<ViewModel: HistoryTableViewModel>: UIViewRepresentable {
  @Environment(\.theme) var theme: Theme
  @Environment(\.appLocale) var appLocale: AppLocale
  @ObservedObject var viewModel: ViewModel
  let selectionComputer: HistorySelectionComputer

  func makeUIView(context: Context) -> UITableView {
    let tableView = CustomTableView()
    tableView.delegate = tableView
    tableView.dataSource = tableView
    tableView.register(HistoryCellView.self)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 44
    tableView.allowsMultipleSelection = false
    tableView.allowsSelection = true
    tableView.allowsSelectionDuringEditing = true
    tableView.allowsMultipleSelectionDuringEditing = false
    tableView.didRemove = viewModel.didRemove(at:)
    tableView.didSelect = { viewModel.selectedIndex = $0 }
    tableView.didShare = viewModel.didShare(at:)
    tableView.selectionComputer = selectionComputer
    return tableView
  }

  func updateUIView(_ uiView: UITableView, context: Context) {
    guard let customTableView = uiView as? CustomTableView else { return }
    let needsReload = customTableView.theme.textColor != theme.textColor ||
      customTableView.locale.currentLocale != appLocale.currentLocale ||
      viewModel.cells != customTableView.cells ||
      customTableView.selectedIndexPath.row != viewModel.selectedIndex
    customTableView.theme = theme
    customTableView.locale = appLocale
    customTableView.backgroundColor = UIColor(theme.mainBackgroundColor)
    customTableView.separatorColor = UIColor(theme.disabledTextColor)
    customTableView.cells = viewModel.cells
    customTableView.selectedIndexPath = IndexPath(row: viewModel.selectedIndex, section: 0)
    guard needsReload else { return }
    customTableView.reloadData()
  }
}

private final class CustomTableView: UITableView {
  var selectionComputer: HistorySelectionComputer!
  var theme: Theme = Default.theme
  var locale: AppLocale = Default.appLocale
  var cells = [HistoryCellViewModel]()
  var didRemove: (Int) -> Void = { _ in }
  var didSelect: (Int) -> Void = { _ in }
  var didShare: (Int) -> Void = { _ in }
  var selectedIndexPath = IndexPath(row: 0, section: 0)

  override func reloadData() {
    super.reloadData()
    selectCurrentRow()
  }

  func selectCurrentRow() {
    let cell = cellForRow(at: selectedIndexPath)
    let historyCell = cell as? HistoryCellView
    historyCell?.setSelected()
    selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
  }
}

extension CustomTableView: UITableViewDelegate {
}

extension CustomTableView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    cells.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeue(HistoryCellView.self, for: indexPath)
    cell.theme = theme
    cell.locale = locale
    cell.viewModel = cells[indexPath.row]
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedIndexPath = indexPath
    didSelect(indexPath.row)
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    true
  }

  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    .delete
  }

  func tableView(
    _ tableView: UITableView,
    commit editingStyle: UITableViewCell.EditingStyle,
    forRowAt indexPath: IndexPath
  ) {
    guard editingStyle == .delete else { return }
    performRemove(at: indexPath)
  }

  func tableView(
    _ tableView: UITableView,
    contextMenuConfigurationForRowAt indexPath: IndexPath,
    point: CGPoint
  ) -> UIContextMenuConfiguration? {
    UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
      guard let self = self else { return UIMenu(title: "", children: []) }
      let children = [
        UIAction(title: self.locale.playString, sfSymbol: .play) { [weak self] in self?.didSelect(indexPath.row) },
        UIAction(title: self.locale.shareString, sfSymbol: .share) { [weak self] in self?.didShare(indexPath.row) },
        UIAction(title: self.locale.deleteString, sfSymbol: .trash, attributes: .destructive) { [weak self] in
          self?.performRemove(at: indexPath)
        },
      ]
      return UIMenu(title: "", children: children)
    }
  }

  private func performRemove(at indexPath: IndexPath) {
    let newSelection = selectionComputer.computeSelection(
      cells: cells,
      selectedIndex: selectedIndexPath.row,
      indexToRemove: indexPath.row
    )
    cells.remove(at: indexPath.row)
    deleteRows(at: [indexPath], with: .automatic)
    if !cells.isEmpty {
      selectedIndexPath = IndexPath(row: newSelection, section: 0)
      selectCurrentRow()
    }
    didRemove(indexPath.row)
  }
}

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

  @Published var cells = [
    HistoryCellViewModel(
      id: URL(string: "/dev/null")!,
      preview: .cameraPreview,
      date: Date(),
      duration: .from(minutes: 2),
      fileSize: .from(megabytes: 2)
    ),
    HistoryCellViewModel(
      id: URL(string: "/dev/null/2")!,
      preview: .cameraPreview,
      date: Date(),
      duration: .from(minutes: 2),
      fileSize: .from(megabytes: 2)
    ),
    HistoryCellViewModel(
      id: URL(string: "/dev/null/3")!,
      preview: .cameraPreview,
      date: Date(),
      duration: .from(minutes: 2),
      fileSize: .from(megabytes: 2)
    ),
  ]
  var cellsPublished: Published<[HistoryCellViewModel]> { _cells }
  var cellsPublisher: Published<[HistoryCellViewModel]>.Publisher { $cells }

  @Published var selectedIndex = 0
  var selectedIndexPublished: Published<Int> { _selectedIndex }
  var selectedIndexPublisher: Published<Int>.Publisher { $selectedIndex }
}

#if DEBUG

struct HistoryTableViewPreview: PreviewProvider {
  static var previews: some View {
    locator.resolve(HistoryTableViewBuilder.self).makeView()
  }
}

#endif
