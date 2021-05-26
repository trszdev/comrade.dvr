import UIKit

extension UIAction {
  convenience init(
    title: String,
    sfSymbol: SFSymbol,
    attributes: UIMenuElement.Attributes = .init(),
    handler: @escaping () -> Void
  ) {
    self.init(
      title: title,
      image: UIImage(sfSymbol: sfSymbol),
      identifier: nil,
      attributes: attributes,
      handler: { _ in handler() }
    )
  }
}
