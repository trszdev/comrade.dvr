import UIKit
import SwiftUI

public enum Appearance: String, Equatable {
  case dark
  case light

  internal var traitCollection: UITraitCollection {
    switch self {
    case .dark:
      return .init(userInterfaceStyle: .dark)
    case .light:
      return .init(userInterfaceStyle: .light)
    }
  }
}

public extension Optional where Wrapped == Appearance {
  func color(_ colorAsset: ColorAsset) -> Color {
    colorAsset.color(for: self)
  }

  func image(_ imageAsset: ImageAsset) -> Image {
    imageAsset.image(for: self)
  }

  var interfaceStyle: UIUserInterfaceStyle {
    switch self {
    case .none:
      return .unspecified
    case .dark:
      return .dark
    case .light:
      return .light
    }
  }
}
