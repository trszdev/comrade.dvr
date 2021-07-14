import SwiftUI
import AutocontainerKit

final class HistoryTableViewBuilder: AKBuilder {
  func makeView() -> AnyView {
    HistoryTableView(viewModel: resolve(HistoryTableViewModelImpl.self)).eraseToAnyView()
  }
}

struct HistoryTableView<ViewModel: HistoryTableViewModel>: UIViewRepresentable {
  @Environment(\.theme) var theme: Theme
  @Environment(\.appLocale) var appLocale: AppLocale
  let viewModel: ViewModel

  func makeUIView(context: Context) -> UITableView {
    let tableView = CustomTableView()
    tableView.delegate = tableView
    tableView.dataSource = tableView
    tableView.register(HistoryCellView.self)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 44
    tableView.didRemove = viewModel.didRemove(cell:)
    return tableView
  }

  func updateUIView(_ uiView: UITableView, context: Context) {
    guard let customTableView = uiView as? CustomTableView else { return }
    customTableView.theme = theme
    customTableView.locale = appLocale
    customTableView.cells = viewModel.cells
    customTableView.backgroundColor = UIColor(theme.mainBackgroundColor)
    customTableView.separatorColor = UIColor(theme.disabledTextColor)
    customTableView.reloadData()
  }
}

private final class CustomTableView: UITableView {
  var theme: Theme = Default.theme
  var locale: AppLocale = Default.appLocale
  var cells = [HistoryCellViewModel]()
  var didRemove: (HistoryCellViewModel) -> Void = { _ in }
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
    cell.selectionStyle = .none
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    didRemove(cells[indexPath.row])
  }

  func tableView(
    _ tableView: UITableView,
    contextMenuConfigurationForRowAt indexPath: IndexPath,
    point: CGPoint
  ) -> UIContextMenuConfiguration? {
    UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
      guard let self = self else { return UIMenu(title: "", children: []) }
      let children = [
        UIAction(title: self.locale.playString, sfSymbol: .play, handler: {}),
        UIAction(title: self.locale.shareString, sfSymbol: .share, handler: {}),
        UIAction(title: self.locale.deleteString, sfSymbol: .trash, attributes: .destructive, handler: {}),
      ]
      return UIMenu(title: "", children: children)
    }
  }
}

#if DEBUG

struct HistoryTableViewPreview: PreviewProvider {
  static var previews: some View {
    locator.resolve(HistoryTableViewBuilder.self).makeView()
  }
}

#endif
