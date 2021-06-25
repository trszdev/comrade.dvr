import AutocontainerKit
import SwiftUI

struct TableViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.transient.autoregister(construct: TablePickerCellViewBuilder.init(locator:))
    container.transient.autoregister(construct: TableSliderCellViewBuilder.init(locator:))
  }
}
