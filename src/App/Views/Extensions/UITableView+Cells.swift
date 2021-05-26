import UIKit

extension UITableView {
  func register<Cell: UITableViewCell>(_ type: Cell.Type) {
    let reuseId = String(describing: Cell.self)
    register(Cell.self, forCellReuseIdentifier: reuseId)
  }

  func registerHeaderFooter<HeaderFooter: UITableViewHeaderFooterView>(_ type: HeaderFooter.Type) {
    let reuseId = String(describing: HeaderFooter.self)
    register(HeaderFooter.self, forHeaderFooterViewReuseIdentifier: reuseId)
  }

  func dequeue<Cell: UITableViewCell>(_ type: Cell.Type, for indexPath: IndexPath) -> Cell {
    let reuseId = String(describing: Cell.self)
    let cell = dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
    // swiftlint:disable force_cast
    return cell as! Cell
  }
}
