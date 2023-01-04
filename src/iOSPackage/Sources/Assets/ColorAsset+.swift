import SwiftUI

public extension ColorAsset {
  func color(for appearance: Appearance? = nil) -> Color {
    .init(uiColor(for: appearance).cgColor)
  }

  func uiColor(for appearance: Appearance? = nil) -> UIColor {
    let color = UIColor(named: rawValue, in: .module, compatibleWith: nil) ?? .clear
    return color.resolvedColor(with: appearance?.traitCollection ?? .current)
  }
}
