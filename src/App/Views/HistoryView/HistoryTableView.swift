import SwiftUI

struct HistoryTableView: UIViewRepresentable {
  @Environment(\.theme) var theme: Theme
  @Environment(\.locale) var locale: Locale

  func makeUIView(context: Context) -> UITableView {
    let tableView = CustomTableView()
    tableView.delegate = tableView
    tableView.dataSource = tableView
    tableView.register(HistoryCellView.self)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 44
    return tableView
  }

  func updateUIView(_ uiView: UITableView, context: Context) {
    uiView.reloadData()
    guard let customTableView = uiView as? CustomTableView else { return }
    customTableView.theme = theme
    customTableView.locale = locale
    customTableView.backgroundColor = UIColor(theme.mainBackgroundColor)
    customTableView.separatorColor = UIColor(theme.disabledTextColor)
  }
}

private class CustomTableView: UITableView {
  var theme: Theme = Default.theme
  var locale: Locale = Default.locale
}

extension CustomTableView: UITableViewDelegate {
}

extension CustomTableView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    20
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeue(HistoryCellView.self, for: indexPath)
    cell.theme = theme
    cell.locale = locale
    cell.viewModel = Default.historyCellViewModel
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
    print("\(indexPath.row) delete=\(editingStyle == .delete)")
  }

  func tableView(
    _ tableView: UITableView,
    contextMenuConfigurationForRowAt indexPath: IndexPath,
    point: CGPoint
  ) -> UIContextMenuConfiguration? {
    UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [locale] _ in
      let children = [
        UIAction(title: locale.playString, sfSymbol: .play, handler: {}),
        UIAction(title: locale.shareString, sfSymbol: .share, handler: {}),
        UIAction(title: locale.deleteString, sfSymbol: .trash, attributes: .destructive, handler: {}),
      ]
      return UIMenu(title: "", children: children)
    }
  }
}

#if DEBUG

struct HistoryTableViewPreview: PreviewProvider {
  static var previews: some View {
    HistoryTableView()
      .environment(\.theme, DarkTheme())
      .environment(\.locale, LocaleImpl(languageCode: .ru))
  }
}

#endif
