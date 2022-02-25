import SwiftUI

public struct IntSlider: View {
  public init(value: Binding<Int>, in range: ClosedRange<Int>) {
    self.value = value
    self.range = range
  }

  public var body: some View {
    Slider(
      value: .init { Double(value.wrappedValue) } set: { value.wrappedValue = Int($0) },
      in: .init(uncheckedBounds: (lower: Double(range.lowerBound), upper: Double(range.upperBound) )),
      step: 1
    )
  }

  private let value: Binding<Int>
  private let range: ClosedRange<Int>
}
