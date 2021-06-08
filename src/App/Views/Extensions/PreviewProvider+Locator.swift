import SwiftUI
import AutocontainerKit

#if DEBUG

extension PreviewProvider {
  static var locator: AKLocator {
    previewContainer
  }
}

private let previewContainer = AppAssembly(isPreview: true).hashContainer

#endif
