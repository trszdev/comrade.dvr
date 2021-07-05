import SwiftUI
import AutocontainerKit

#if DEBUG

extension PreviewProvider {
  static var locator: AKLocator {
    previewLocator
  }
}

private let previewLocator = AppAssembly(isPreview: true).locator

#endif
