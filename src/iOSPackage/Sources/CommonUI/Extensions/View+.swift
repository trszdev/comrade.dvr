import SwiftUI

public extension View {
  @inlinable
  func reverseMask<Mask: View>(_ mask: Mask) -> some View {
    self.mask(
      Rectangle()
        .overlay(
          mask
            .blendMode(.destinationOut)
        )
    )
  }
}
