import UIKit
import SwiftUI

public extension ImageAsset {
  func uiImage(for appearance: Appearance? = nil) -> UIImage {
    .init(named: rawValue, in: .module, compatibleWith: appearance?.traitCollection ?? .current) ?? .init()
  }

  func image(for appearance: Appearance? = nil) -> Image {
    .init(uiImage: uiImage(for: appearance))
  }
}
